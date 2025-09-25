import Foundation

public struct StoreDetailMenu: Hashable {
    public let name: String?
    public let description: String?
    public let category: StoreFoodCategoryResponse
    
    public init(response: UserStoreMenuResponseV3) {
        self.name = response.name
        self.description = response.description
        self.category = response.category
    }
}

public extension StoreDetailMenu {
    var isValid: Bool {
        if let name = name,
           let description {
            return !name.isEmpty || !description.isEmpty
        } else {
            return false
        }
    }
}
