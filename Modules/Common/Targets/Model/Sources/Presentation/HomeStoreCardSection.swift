import Foundation

public struct HomeSection: Hashable {
    public var items: [HomeSectionItem]
    
    public init(items: [HomeSectionItem]) {
        self.items = items
    }
}

public enum HomeSectionItem: Hashable {
    case storeCard(StoreCard)
    case empty
    case advertisement(Advertisement?)
}

public extension HomeSectionItem {
    var storeCard: StoreCard? {
        if case .storeCard(let storeCard) = self {
            return storeCard
        } else {
            return nil
        }
    }
    
    var advertisement: Advertisement? {
        if case .advertisement(let advertisement) = self {
            return advertisement
        } else {
            return nil
        }
    }
}
