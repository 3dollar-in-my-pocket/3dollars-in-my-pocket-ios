import Foundation

public struct StoreMenuRequest: Encodable {
    public let name: String
    public let price: String
    public let category: String
    
    public init(name: String, price: String, category: String) {
        self.name = name
        self.price = price
        self.category = category
    }
}
