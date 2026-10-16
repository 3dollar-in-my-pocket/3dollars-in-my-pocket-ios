import Foundation

import Common
import Model
import Networking

final class StoreThreadPostEmbedLoader {
    private static let instagramHost = "instagram.com"
    private static let instagramEmbedScriptURL = "https://platform.instagram.com/en_US/embeds.js"

    private let repository: ThreadsRepository
    private var htmls: [String: String] = [:]
    private var failedPermalinks = Set<String>()

    init(repository: ThreadsRepository) {
        self.repository = repository
    }

    func applyEmbeds(to sections: [any StoreSectionComponent]) -> [any StoreSectionComponent] {
        registerInstagramEmbeds(in: sections)
        return sections.map { section in
            switch section {
            case let threadPostSection as StoreThreadPostSection:
                return StoreThreadPostEmbedSection(section: threadPostSection, htmls: htmls, failedPermalinks: failedPermalinks)
            case let embedSection as StoreThreadPostEmbedSection where embedSection.embeds == nil:
                return embedSection.resolved(htmls: htmls, failedPermalinks: failedPermalinks)
            default:
                return section
            }
        }
    }

    func fetchPendingEmbeds(in sections: [any StoreSectionComponent]) async -> Bool {
        let pendingPermalinks = Set(
            sections
                .compactMap { $0 as? StoreThreadPostEmbedSection }
                .filter { $0.embeds == nil }
                .flatMap(\.permalinks)
                .filter { htmls[$0] == nil && failedPermalinks.contains($0).isNot }
        )
        guard pendingPermalinks.isEmpty.isNot else { return false }

        let fetchedHTMLs = await fetchHTMLs(permalinks: Array(pendingPermalinks))
        pendingPermalinks.forEach { permalink in
            if let html = fetchedHTMLs[permalink] {
                htmls[permalink] = html
            } else {
                failedPermalinks.insert(permalink)
            }
        }
        return true
    }

    private func registerInstagramEmbeds(in sections: [any StoreSectionComponent]) {
        sections
            .compactMap { $0 as? StoreThreadPostSection }
            .flatMap(\.cards)
            .filter { $0.platform == .instagram && htmls[$0.permalink] == nil }
            .forEach { card in
                if let html = Self.instagramEmbedHTML(permalink: card.permalink) {
                    htmls[card.permalink] = html
                } else {
                    failedPermalinks.insert(card.permalink)
                }
            }
    }

    static func instagramEmbedHTML(permalink: String) -> String? {
        guard let url = URL(string: permalink),
              url.scheme == "https",
              let host = url.host,
              host == instagramHost || host.hasSuffix(".\(instagramHost)") else { return nil }
        let escapedPermalink = url.absoluteString
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        return """
        <blockquote class="instagram-media" data-instgrm-permalink="\(escapedPermalink)" data-instgrm-version="14"></blockquote>
        <script async src="\(instagramEmbedScriptURL)"></script>
        """
    }

    private func fetchHTMLs(permalinks: [String]) async -> [String: String] {
        let repository = repository
        return await withTaskGroup(of: (String, String?).self) { group in
            permalinks.forEach { permalink in
                group.addTask {
                    let html = try? await repository.fetchOEmbed(url: permalink).get().html
                    return (permalink, html)
                }
            }
            var htmls: [String: String] = [:]
            for await (permalink, html) in group {
                htmls[permalink] = html
            }
            return htmls
        }
    }
}
