import Foundation

public struct BossStoreDetailData {
    public var overview: StoreDetailOverview
    public let info: BossStoreInfo
    public let menus: [BossStoreMenu]
    public var workdays: [BossStoreAppearanceDay]
    public var feedbacks: [FeedbackCountWithRatioResponse]
    public var store: BossStoreResponse
    public let post: PostResponse?
    public let totalPostCount: Int?

    public init(response: BossStoreDetailResponse) {
        self.overview = StoreDetailOverview(
            categories: response.store.categories,
            repoterName: "",
            storeName: response.store.name,
            isNew: response.tags.isNew,
            totalVisitSuccessCount: 0,
            reviewCount: response.feedbacks.map { $0.count }.reduce(0, +),
            distance: response.distanceM,
            location: response.store.location,
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
            images: response.store.representativeImages,
            accountInfos: response.store.accountNumbers.map { StoreAccountNumber(response: $0 )},
            contactsNumbers: response.store.contactsNumbers
        )
        self.menus = response.store.menus.map { BossStoreMenu(response: $0) }
        
        
        self.workdays = response.store.appearanceDays.map {
            BossStoreAppearanceDay(response: $0)
        }
        self.feedbacks = response.feedbacks
        self.store = response.store
        if let post = response.newsPosts.contents.first {
            self.post = post
            self.totalPostCount = response.newsPosts.cursor.totalCount
        } else {
            self.post = nil
            self.totalPostCount = nil
        }
    }
}
