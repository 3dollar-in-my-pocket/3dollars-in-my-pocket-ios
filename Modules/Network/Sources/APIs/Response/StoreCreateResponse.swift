import Foundation

public struct StoreCategoryResponse: Decodable {
    let storeId: Int
    let userId: Int
    let storeName: String
    let salesType: String
    let latitude: Double
    let longitude: Double
    let address: AddressResponse
    let rating: Double
    let isDeleted: Bool
    let categories: [String]
    let createdAt: String?
    let updatedAt: String?
}
