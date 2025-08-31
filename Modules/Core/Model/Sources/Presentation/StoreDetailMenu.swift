import Foundation

public struct StoreDetailMenu: Hashable {
    public let name: String?
    public let count: Int?
    public let price: String?
    public let category: StoreFoodCategoryResponse
    
    public init(response: UserStoreMenuResponse) {
        self.name = response.name
        self.price = response.price
        self.category = response.category
        self.count = nil
    }
    
    public init(response: UserStoreMenuResponseV3) {
        self.name = response.name
        self.price = response.price.map { "\($0)" }
        self.category = response.category
        self.count = response.count
    }
}

public extension StoreDetailMenu {
    var isValid: Bool {
        if let name = name,
           let price = price {
            return !name.isEmpty || !price.isEmpty
        } else {
            return false
        }
    }
}
