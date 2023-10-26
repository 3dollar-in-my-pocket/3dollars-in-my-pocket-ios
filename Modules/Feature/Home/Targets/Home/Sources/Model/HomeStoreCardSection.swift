import Foundation

import Model

struct HomeSection: Hashable {
    var items: [HomeSectionItem]
}

enum HomeSectionItem: Hashable {
    case storeCard(StoreCard)
    case empty
    case advertisement(Advertisement?)
}
