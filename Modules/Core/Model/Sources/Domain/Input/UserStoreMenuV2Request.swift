import Foundation

public struct UserStoreMenuV2Request: Encodable {
    public let name: String
    public let count: Int
    public let price: Int
    public let category: String
    public let description: String?
    
    public init(
        name: String,
        count: Int,
        price: Int,
        category: String,
        description: String?
    ) {
        self.name = name
        self.count = count
        self.price = price
        self.category = category
        self.description = description
    }
}
