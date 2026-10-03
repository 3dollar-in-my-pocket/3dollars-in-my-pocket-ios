import Foundation

public struct StoreMenuExtractionListResponse: Decodable {
    public let imageUrl: String
    public let menus: [StoreMenuExtractionResponse]
}

public struct StoreMenuExtractionResponse: Decodable {
    public let name: String
    public let count: Int?
    public let price: Int?
    public let category: StoreFoodCategoryResponse
}
