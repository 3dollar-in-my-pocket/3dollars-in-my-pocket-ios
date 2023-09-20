import Foundation

public struct StoreDetailOverview: Hashable {
    public let categories: [PlatformStoreCategory]
    public let repoterName: String
    public let storeName: String
    public let isNew: Bool
    public let totalVisitSuccessCount: Int
    public let reviewCount: Int
    public let distance: Int
    public let location: Location
    public let address: String
    public var isFavorited: Bool
    public var subscribersCount: Int
}
