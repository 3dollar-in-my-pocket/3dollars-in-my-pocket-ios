import Foundation

public struct BossStoreDetailData {
    public var overview: StoreDetailOverview
    public let info: BossStoreInfo
    public let menus: [BossStoreMenu]
    public var workdays: [BossStoreAppearanceDay]
    public var feedbacks: [FeedbackCountWithRatioResponse]
    public var store: BossStoreDetailApiResponse

    public init(response: BossStoreWithDetailApiResponse) {
        self.overview = StoreDetailOverview(
            categories: response.store.categories.map { PlatformStoreCategory(response: $0) },
            repoterName: "",
            storeName: response.store.name,
            isNew: response.tags.isNew,
            totalVisitSuccessCount: 0,
            reviewCount: response.feedbacks.map { $0.count }.reduce(0, +),
            distance: response.distanceM,
            location: Location(response: response.store.location ?? .init(latitude: 0, longitude: 0)),
            address: response.store.address.fullAddress,
            isFavorited: response.favorite.isFavorite,
            subscribersCount: response.favorite.totalSubscribersCount,
            isBossStore: true,
            snsUrl: response.store.snsUrl,
            introduction: response.store.introduction
        )
        self.info = BossStoreInfo(
            updatedAt: response.store.updatedAt,
            snsUrl: response.store.snsUrl,
            introduction: response.store.introduction,
            imageUrl: response.store.imageUrl,
            accountInfos: response.store.accountNumbers.map { StoreAccountNumber(response: $0 )}
        )
        self.menus = response.store.menus.map { BossStoreMenu(response: $0) }
        
        
        self.workdays = response.store.appearanceDays.map {
            BossStoreAppearanceDay(response: $0)
        }
        self.feedbacks = response.feedbacks
        self.store = response.store
    }
}
