import Foundation

public struct BossStoreResponse: Decodable {
    public let storeId: String
    public let isOwner: Bool
    public let name: String
    public let location: LocationResponse?
    public let address: AddressResponse
    public let representativeImages: [ImageResponse]
    public let introduction: String?
    public let snsUrl: String?
    public let menus: [BossStoreMenuResponse]
    public let appearanceDays: [StoreAppearanceDayResponse]
    public let categories: [StoreFoodCategoryResponse]
    public let accountNumbers: [StoreAccountNumberResponse]
    public let activitiesStatus: ActivitiesStatus
    public let createdAt: String
    public let updatedAt: String
}


public enum ActivitiesStatus: String, Decodable {
    case recentActivity = "RECENT_ACTIVITY"
    case noRecentActivity = "NO_RECENT_ACTIVITY"
    case unknown
    
    public init(from decoder: Decoder) throws {
        self = try ActivitiesStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
