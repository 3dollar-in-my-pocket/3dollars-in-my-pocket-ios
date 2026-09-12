import Foundation

public struct StoreImageSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let header: SDHeader
    public let cards: [StoreImageSectionCard]
}

public struct StoreImageSectionCard: Decodable, Equatable, Hashable {
    public let cardId: String
    public let image: SDImage
    public let title: SDText?
    public let subTitle: SDText?
    public let link: SDLink?
    public let customAction: SDCustomAction?
    public let style: SDSurfaceStyle
    public let clickLog: SDClickLog?
}
