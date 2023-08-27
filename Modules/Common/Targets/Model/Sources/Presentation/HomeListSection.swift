import Foundation

public struct HomeListSection: Hashable {
    var items: [HomeListSectionItem]
}
        
public enum HomeListSectionItem: Hashable {
    case storeCard(StoreCard)
}
