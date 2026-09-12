import Foundation

public struct StorePostSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let header: SDHeader
    public let cards: [StorePostContentCard]
}

public struct StorePostContentCard: Decodable, Equatable, Hashable {
    public let cardId: String
    public let header: SDChip
    public let images: [SDImage]
    public let body: SDText
    public let like: SDToggleAction?
    public let link: SDLink?
    public let style: SDSurfaceStyle
    public let clickLog: SDClickLog?
}
