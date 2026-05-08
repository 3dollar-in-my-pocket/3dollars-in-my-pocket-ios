import Foundation

public struct HomeFilterScreenResponse: Decodable {
    public let sections: [any HomeScreenSection]

    public enum CodingKeys: String, CodingKey {
        case sections
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        var sectionsArray = try container.nestedUnkeyedContainer(forKey: .sections)
        var tempContainer = sectionsArray
        var sections: [any HomeScreenSection] = []

        while !sectionsArray.isAtEnd {
            let preview = try sectionsArray.decode(SectionTypePreview.self)
            let sectionDecoder = try tempContainer.superDecoder()

            switch preview.type {
            case .homeFilter:
                sections.append(try HomeFilterSection(from: sectionDecoder))
            case .unknown:
                continue
            }
        }
        self.sections = sections
    }
}

private struct SectionTypePreview: Decodable {
    let type: HomeScreenSectionType
}
