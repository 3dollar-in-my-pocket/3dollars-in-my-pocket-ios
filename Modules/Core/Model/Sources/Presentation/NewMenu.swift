import Foundation

public struct NewMenu: Hashable {
    public let category: PlatformStoreCategory
    public var name: String
    public var price: String
    
    public init(
        category: PlatformStoreCategory,
        name: String = "",
        price: String = ""
    ) {
        self.category = category
        self.name = name
        self.price = price
    }
}

public extension NewMenu {
    var isValid: Bool {
        return !name.isEmpty && !price.isEmpty
    }
}
