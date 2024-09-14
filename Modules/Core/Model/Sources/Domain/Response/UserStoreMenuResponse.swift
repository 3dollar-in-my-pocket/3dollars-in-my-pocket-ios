import Foundation

public struct UserStoreMenuResponse: Decodable {
    public let name: String
    public let price: String
    public let category: StoreFoodCategoryResponse
}
