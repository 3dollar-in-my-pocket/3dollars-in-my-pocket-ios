import Foundation

public struct HomeListSection: Hashable {
    public var items: [HomeListSectionItem]
    
    public init(items: [HomeListSectionItem]) {
        self.items = items
    }
}
        
public enum HomeListSectionItem: Hashable {
    case storeCard(StoreCard)
}
