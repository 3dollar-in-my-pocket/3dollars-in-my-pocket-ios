import Model

struct StoreThreadPostEmbedSection: StoreSectionComponent {
    struct Embed: Decodable, Hashable {
        let permalink: String
        let html: String
        let clickLog: SDClickLog?
    }

    let sectionId: String?
    let style: SDSurfaceStyle?
    let header: SDHeader
    let impressionLog: SDImpressionLog?
    let cards: [StoreThreadPostCard]
    let embeds: [Embed]?

    var type: StoreSectionType { .threadPost }

    var permalinks: [String] {
        cards.map(\.permalink)
    }

    init(section: StoreThreadPostSection, htmls: [String: String], failedPermalinks: Set<String>) {
        var seenPermalinks = Set<String>()
        let cards = section.cards.filter {
            $0.platform != .unknown && !$0.permalink.isEmpty && seenPermalinks.insert($0.permalink).inserted
        }
        self.init(
            sectionId: section.sectionId,
            style: section.style,
            header: section.header,
            impressionLog: section.impressionLog,
            cards: cards,
            htmls: htmls,
            failedPermalinks: failedPermalinks
        )
    }

    private init(
        sectionId: String?,
        style: SDSurfaceStyle?,
        header: SDHeader,
        impressionLog: SDImpressionLog?,
        cards: [StoreThreadPostCard],
        htmls: [String: String],
        failedPermalinks: Set<String>
    ) {
        self.sectionId = sectionId
        self.style = style
        self.header = header
        self.impressionLog = impressionLog
        self.cards = cards
        let isResolved = cards.allSatisfy { htmls[$0.permalink] != nil || failedPermalinks.contains($0.permalink) }
        self.embeds = isResolved ? cards.compactMap { card in
            htmls[card.permalink].map { Embed(permalink: card.permalink, html: $0, clickLog: card.clickLog) }
        } : nil
    }

    func resolved(htmls: [String: String], failedPermalinks: Set<String>) -> StoreThreadPostEmbedSection {
        StoreThreadPostEmbedSection(
            sectionId: sectionId,
            style: style,
            header: header,
            impressionLog: impressionLog,
            cards: cards,
            htmls: htmls,
            failedPermalinks: failedPermalinks
        )
    }
}
