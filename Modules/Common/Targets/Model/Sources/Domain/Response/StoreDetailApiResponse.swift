import Foundation

public struct StoreDetailApiResponse: Decodable {
    public let storeId: Int
    public let name: String
    public let salesType: String?
    public let rating: Int
    public let location: LocationResponse
    public let address: AddressResponse
    public let categories: [PlatformStoreFoodCategoryResponse]
    public let appearanceDays: [String]
    public let paymentMethods: [String]
    public let menus: [StoreMenuApiResponse]
    public let createdAt: String
    public let updatedAt: String
}
