import Foundation

public struct StoreMenuApiResponse: Decodable {
    public let menuId: Int
    public let name: String?
    public let price: String?
    public let category: PlatformStoreFoodCategoryResponse
}
