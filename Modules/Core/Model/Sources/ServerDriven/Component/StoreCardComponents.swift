import Foundation

public protocol StoreCardComponent: Equatable, Hashable, Decodable {
    var type: SDComponentType { get }
}

public struct StoreRelatedStoresSectionResponse: Decodable, Hashable, StoreCardComponent {
    public let type: SDComponentType
    public let header: StoreRelatedStoresSectionHeaderResponse
    public let cards: [StoreImagePreviewCard]
}

public struct StoreRelatedStoresSectionHeaderResponse: Decodable, Hashable {
    public let title: SDText
}

public struct StoreImagePreviewCard: Decodable, Hashable, StoreCardComponent {
    public let type: SDComponentType
    public let cardId: String
    public let image: SDImage
    public let title: SDText
    public let metricLabel: [SDChip]
    public let contextLabel: [SDChip]
    public let link: SDLink?
    public let refs: [StoreReferenceResponse]
}

public struct StoreReferenceResponse: Decodable, Hashable {
    public let type: String
    public let storeId: String
    public let storeType: String
}
