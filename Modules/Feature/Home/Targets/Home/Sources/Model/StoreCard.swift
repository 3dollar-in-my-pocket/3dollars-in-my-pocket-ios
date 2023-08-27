import Foundation

import Networking

struct StoreCard {
    let storeType: StoreType
    let storeId: String
    let storeName: String
    let location: Location?
    let categories: [PlatformStoreCategory]
    let distance: Int
    let reviewsCount: Int?
    let rating: Double?
    let existsCounts: Int?
    let isNew: Bool
    
    init(response: PlatformStoreWithDetailResponse) {
        self.storeType = StoreType(value: response.store.storeType)
        self.storeId = response.store.storeId
        self.storeName = response.store.storeName
        self.location = Location(response: response.store.location)
        self.categories = response.store.categories.map(PlatformStoreCategory.init(response:))
        self.distance = response.distanceM
        self.reviewsCount = response.extra.reviewsCount
        self.rating = response.extra.rating
        self.existsCounts = response.extra.visitCounts?.existsCounts
        self.isNew = response.extra.tags.isNew
    }
}

extension StoreCard {
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
    static func == (lhs: StoreCard, rhs: StoreCard) -> Bool {
        return lhs.storeId == rhs.storeId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(storeId)
    }
}
