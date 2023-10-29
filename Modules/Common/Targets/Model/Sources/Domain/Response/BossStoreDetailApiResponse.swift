import Foundation

public struct BossStoreDetailApiResponse: Decodable {
    public let storeId: String
    public let isOwner: Bool
    public let name: String
    public let location: LocationResponse?
    public let address: AddressResponse
    public let imageUrl: String?
    public let introdution: String?
    public let snsUrl: String?
    public let menus: [BossStoreMenuApiResponse]
    public let appearanceDays: [BossStoreAppearanceDayApiResponse]
    public let categories: [PlatformStoreFoodCategoryResponse]
    public let createdAt: String
    public let updatedAt: String
}
