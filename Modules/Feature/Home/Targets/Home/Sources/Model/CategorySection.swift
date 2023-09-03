import Foundation

struct CategorySection: Hashable {
    var title: String
    var items: [CategorySectionItem]
}

enum CategorySectionItem: Hashable {
    case category(PlatformStoreCategory)
    case advertisement(Advertisement?)
}