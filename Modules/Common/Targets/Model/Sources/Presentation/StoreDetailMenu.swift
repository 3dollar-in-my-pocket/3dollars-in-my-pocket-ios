import Foundation

public struct StoreDetailMenu: Hashable {
    public let menuId: Int
    public let name: String?
    public let price: String?
    public let category: PlatformStoreCategory
    
    public init(response: StoreMenuApiResponse) {
        self.menuId = response.menuId
        self.name = response.name
        self.price = response.price
        self.category = PlatformStoreCategory(response: response.category)
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
