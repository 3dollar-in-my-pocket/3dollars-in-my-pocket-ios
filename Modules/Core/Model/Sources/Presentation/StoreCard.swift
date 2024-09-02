import Foundation

public struct StoreCard {
    public let storeType: StoreType
    public let storeId: String
    public let storeName: String
    public let location: Location?
    public let categories: [PlatformStoreCategory]
    public let distance: Int
    public let reviewsCount: Int?
    public let rating: Double?
    public let existsCounts: Int?
    public let isNew: Bool
    
//    public init(response: PlatformStoreWithDetailResponse) {
//        self.storeType = response.store.storeType
//        self.storeId = response.store.storeId
//        self.storeName = response.store.storeName
//        self.location = Location(response: response.store.location)
//        self.categories = response.store.categories.map(PlatformStoreCategory.init(response:))
//        self.distance = response.distanceM
//        self.reviewsCount = response.extra.reviewsCount
//        self.rating = response.extra.rating
//        self.existsCounts = response.extra.visitCounts?.existsCounts
//        self.isNew = response.extra.tags.isNew
//    }
}

public extension StoreCard {
    /// 카테고리들 나열된 문자열 ex.) #붕어빵 #땅콩과자 #호떡
    var categoriesString: String {
        if categories.count > 3 {
            let splitedCategories = categories[..<3]
            
            return splitedCategories.map { "#\($0.name)"}.joined(separator: " ")
        } else {
            return categories.map { "#\($0.name)"}.joined(separator: " ")
        }
    }
}

extension StoreCard: Hashable {
    public static func == (lhs: StoreCard, rhs: StoreCard) -> Bool {
        return lhs.storeId == rhs.storeId
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(storeId)
    }
}

extension StoreCard: VisitableStore {
    public var platformStoreCategories: [PlatformStoreCategory] {
        return categories
    }
    
    public var storeLocation: Location? {
        return location
    }
}
