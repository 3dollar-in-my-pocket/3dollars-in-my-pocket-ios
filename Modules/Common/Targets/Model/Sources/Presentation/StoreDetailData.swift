import Foundation

public struct StoreDetailData {
    public var overview: StoreDetailOverview
    public let visit: StoreDetailVisit
    public let info: StoreDetailInfo
    public let menus: [StoreDetailMenu]
    public var totalPhotoCount: Int
    public var photos: [StoreDetailPhoto]
    public let rating: Double
    public var totalReviewCount: Int
    public var reviews: [StoreDetailReview]
    
    public init(
        response: StoreWithDetailApiResponse,
        totalPhotoCount: Int,
        totalReviewCount: Int
    ) {
        self.overview = StoreDetailOverview(
            categories: response.store.categories.map { PlatformStoreCategory(response: $0) },
            repoterName: response.creator.name,
            storeName: response.store.name,
            isNew: response.tags.isNew,
            totalVisitSuccessCount: response.visits.counts.existsCounts,
            reviewCount: response.reviews.cursor.totalCount,
            distance: response.distanceM,
            location: Location(response: response.store.location),
            address: response.store.address.fullAddress,
            isFavorited: response.favorite.isFavorite,
            subscribersCount: response.favorite.totalSubscribersCount
        )
        
        self.visit = StoreDetailVisit(response: response.visits)
        
        self.info = StoreDetailInfo(
            lastUpdated: response.store.updatedAt,
            salesType: SalesType(value: response.store.salesType),
            appearanceDays: response.store.appearanceDays.map { AppearanceDay(value: $0) },
            paymentMethods: response.store.paymentMethods.map { PaymentMethod(value: $0) }
        )
        
        self.menus = response.store.menus.map { StoreDetailMenu(response: $0) }
        self.totalPhotoCount = totalPhotoCount
        self.photos = response.images.contents.map { StoreDetailPhoto(
            response: $0,
            totalCount: response.images.cursor.totalCount
        ) }
        self.rating = response.store.rating
        self.totalReviewCount = totalReviewCount
        self.reviews = response.reviews.contents.map { StoreDetailReview(response: $0) }
    }
}
