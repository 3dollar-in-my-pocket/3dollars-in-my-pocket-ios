import Foundation

public struct StoreInfoV1Section: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let header: SDHeader
    public let informationCard: InformationCard?
    public let menuCard: MenuCard?
}

public struct InformationCard: Decodable, Equatable, Hashable {
    public let rows: [InformationRow]
    public let style: SDSurfaceStyle
}

public enum InformationRow: Decodable, Equatable, Hashable {
    case trailingText(TrailingTextRow)
    case chipGroup(ChipGroupRow)
    case inlineOption(InlineOptionRow)
    case unknown

    private enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let type = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .type)
        switch type {
        case "TRAILING_TEXT":
            self = .trailingText(try TrailingTextRow(from: decoder))
        case "CHIP_GROUP":
            self = .chipGroup(try ChipGroupRow(from: decoder))
        case "INLINE_OPTION":
            self = .inlineOption(try InlineOptionRow(from: decoder))
        default:
            self = .unknown
        }
    }
}

public struct TrailingTextRow: Decodable, Equatable, Hashable {
    public let label: SDText
    public let value: SDText
}

public struct ChipGroupRow: Decodable, Equatable, Hashable {
    public let label: SDText
    public let chips: [SDChip]
}

public struct InlineOptionRow: Decodable, Equatable, Hashable {
    public let label: SDText
    public let items: [SelectableTextItem]
}

public struct SelectableTextItem: Decodable, Equatable, Hashable {
    public let text: SDText
    public let isSelected: Bool
}

public struct MenuCard: Decodable, Equatable, Hashable {
    public let groups: [MenuGroup]
    public let style: SDSurfaceStyle
}

public struct MenuGroup: Decodable, Equatable, Hashable {
    public let header: SDChip
    public let items: [TextMenuItem]
}

public struct TextMenuItem: Decodable, Equatable, Hashable {
    public let primaryText: SDText
    public let secondaryText: SDText?
}
