import Foundation

public struct UserStoreMenuV2Request: Encodable {
    public var name: String
    public var count: Int
    public var price: Int
    public var category: String
    public var description: String?
    
    public init(
        name: String = "",
        count: Int = 0,
        price: Int = 0,
        category: String = "",
        description: String? = nil
    ) {
        self.name = name
        self.count = count
        self.price = price
        self.category = category
        self.description = description
    }
}
