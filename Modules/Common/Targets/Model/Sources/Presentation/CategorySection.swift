import Foundation

public struct CategorySection: Hashable {
    var title: String
    var items: [CategorySectionItem]
}

public enum CategorySectionItem: Hashable {
    case category(PlatformStoreCategory)
    case advertisement(Advertisement?)
}
