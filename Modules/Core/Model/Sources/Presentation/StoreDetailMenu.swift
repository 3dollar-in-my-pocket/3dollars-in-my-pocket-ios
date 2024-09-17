import Foundation

public struct StoreDetailMenu: Hashable {
    public let name: String?
    public let price: String?
    public let category: StoreFoodCategoryResponse
    
    public init(response: UserStoreMenuResponse) {
        self.name = response.name
        self.price = response.price
        self.category = response.category
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
