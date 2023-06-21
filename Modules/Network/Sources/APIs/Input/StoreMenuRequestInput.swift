import Foundation

public struct StoreMenuRequestInput: Encodable {
    let name: String
    let price: String
    let category: String
    
    public init(name: String, price: String, category: String) {
        self.name = name
        self.price = price
        self.category = category
    }
}
