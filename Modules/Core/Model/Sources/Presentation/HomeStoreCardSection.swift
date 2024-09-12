import Foundation

public struct HomeSection: Hashable {
    public var items: [HomeSectionItem]
    
    public init(items: [HomeSectionItem]) {
        self.items = items
    }
}

public enum HomeSectionItem: Hashable {
    case store(StoreWithExtraResponse)
    case empty
    case advertisement(AdvertisementResponse?)
}

public extension HomeSectionItem {
    var store: StoreWithExtraResponse? {
        if case .store(let storeWithExtra) = self {
            return storeWithExtra
        } else {
            return nil
        }
    }
    
    var advertisement: AdvertisementResponse? {
        if case .advertisement(let advertisement) = self {
            return advertisement
        } else {
            return nil
        }
    }
}
