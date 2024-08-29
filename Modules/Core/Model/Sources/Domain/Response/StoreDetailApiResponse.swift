import Foundation

public struct StoreDetailApiResponse: Decodable {
    public let storeId: Int
    public let name: String
    public let salesType: String?
    public let rating: Double
    public let location: LocationResponse
    public let address: AddressResponse
    public let categories: [StoreFoodCategoryResponse]
    public let appearanceDays: [String]
    public let openingHours: StoreOpeningHoursResponse?
    public let paymentMethods: [String]
    public let menus: [StoreMenuApiResponse]
    public let createdAt: String
    public let updatedAt: String
}
