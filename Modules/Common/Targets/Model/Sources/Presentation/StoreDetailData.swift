import Foundation

public struct StoreDetailData {
    public let overview: StoreDetailOverview
    public let visit: StoreDetailVisit
    public let info: StoreDetailInfo
    public let menus: [StoreDetailMenu]
    public let photos: [StoreDetailPhoto]
    
    public init(response: StoreWithDetailApiResponse) {
        self.overview = StoreDetailOverview(
            categories: response.store.categories.map { PlatformStoreCategory(response: $0) },
            repoterName: response.creator.name,
            storeName: response.store.name,
            isNew: response.tags.isNew,
            totalVisitSuccessCount: response.visits.counts.existsCounts,
            reviewCount: response.reviews.cursor.totalCount,
            distance: response.distanceM,
            location: Location(response: response.store.location),
            address: response.store.address.fullAddress
        )
        
        self.visit = StoreDetailVisit(response: response.visits)
        
        self.info = StoreDetailInfo(
            lastUpdated: response.store.updatedAt,
            salesType: SalesType(value: response.store.salesType),
            appearanceDays: response.store.appearanceDays.map { AppearanceDay(value: $0) },
            paymentMethods: response.store.paymentMethods.map { PaymentMethod(value: $0) }
        )
        
        self.menus = response.store.menus.map { StoreDetailMenu(response: $0) }
        self.photos = response.images.contents.map { StoreDetailPhoto(
            response: $0,
            totalCount: response.images.cursor.totalCount
        ) }
    }
}
