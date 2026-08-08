import Foundation

public struct StoreInfoV1Section: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let header: SDHeader
    public let informationCard: InformationCard?
    public let menuGroupCards: [MenuGroupCard]
}

public struct InformationCard: Decodable, Equatable, Hashable {
    public let rows: [LabelChipRow]
    public let style: SDSurfaceStyle
}

public struct LabelChipRow: Decodable, Equatable, Hashable {
    public let label: SDText
    public let chips: [SDChip]
}

public struct MenuGroupCard: Decodable, Equatable, Hashable {
    public let header: SDChip
    public let items: [TextMenuItem]
    public let style: SDSurfaceStyle
}

public struct TextMenuItem: Decodable, Equatable, Hashable {
    public let primaryText: SDText
    public let secondaryText: SDText?
}
