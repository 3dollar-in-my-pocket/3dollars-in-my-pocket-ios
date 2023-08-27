import Foundation

public struct HomeSection: Hashable {
    var items: [HomeSectionItem]
}

public enum HomeSectionItem: Hashable {
    case storeCard(StoreCard)
    case empty
}
