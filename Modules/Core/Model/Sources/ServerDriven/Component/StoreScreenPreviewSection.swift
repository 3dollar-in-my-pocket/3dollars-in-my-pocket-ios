import Foundation

public struct StoreScreenPreviewSection: Decodable, Equatable, Hashable, StoreSectionComponent {
    public let type: StoreSectionType
    public let header: StorePreviewHeader
    public let metadata: StorePreviewMetadata
    public let actionBars: [SDActionBar]
    public let images: [SDImage]
    public let bodies: [StorePreviewBody]
    public let style: SDSurfaceStyle
    public let additionalInfos: StoreScreenPreviewAdditionalInfos
    public let contributorActionBar: SDActionBar?
}

public struct StoreScreenPreviewAdditionalInfos: Decodable, Equatable, Hashable {
    public let type: String
    public let isSubscriber: Bool?
    public let storeId: String?
    public let storeType: String?
}
