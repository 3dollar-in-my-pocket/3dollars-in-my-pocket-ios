import Foundation

public struct StoreCategoryResponse: Decodable {
    public let storeId: Int
    public let userId: Int
    public let storeName: String
    public let salesType: String?
    public let latitude: Double
    public let longitude: Double
    public let address: AddressResponse
    public let rating: Double
    public let isDeleted: Bool
    public let categories: [String]
    public let createdAt: String?
    public let updatedAt: String?
}
