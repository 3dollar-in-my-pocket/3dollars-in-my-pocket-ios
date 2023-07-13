import Foundation

struct HomeSection: Hashable {
    var items: [HomeSectionItem]
}

enum HomeSectionItem: Hashable {
    case storeCard(StoreCard)
}
