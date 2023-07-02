import Foundation

import Networking

struct StoreCard {
    let storeType: StoreType
    let storeId: String
    let storeName: String
    let location: Location?
    let categories: [Category]
    let distance: Int
    let reviewsCount: Int?
    let rating: Double?
    
    init(response: PlatformStoreWithDetailResponse) {
        self.storeType = StoreType(value: response.store.storeType)
        self.storeId = response.store.storeId
        self.storeName = response.store.storeName
        self.location = Location(response: response.store.location)
        self.categories = response.store.categories.map(Category.init(response:))
        self.distance = response.distanceM
        self.reviewsCount = response.extra.reviewsCount
        self.rating = response.extra.rating
    }
}

struct Category {
    let category: String
    let categoryId: String
    let name: String
    let imageUrl: String
    let disableImageUrl: String
    let description: String
    let classificationType: String
    let isNew: Bool
    
    init(response: PlatformStoreCategoryResponse) {
        self.category = response.category
        self.categoryId = response.categoryId
        self.name = response.name
        self.imageUrl = response.imageUrl
        self.disableImageUrl = response.disableImageUrl
        self.description = response.description
        self.classificationType = response.classificationType
        self.isNew = response.isNew
    }
}
