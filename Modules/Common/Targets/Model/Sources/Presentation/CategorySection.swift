import Foundation

public struct CategorySection: Hashable {
    public var title: String
    public var items: [CategorySectionItem]
    
    public init(title: String, items: [CategorySectionItem]) {
        self.title = title
        self.items = items
    }
}

public enum CategorySectionItem: Hashable {
    case category(PlatformStoreCategory)
    case advertisement(Advertisement?)
}
