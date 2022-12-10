struct BossStore {
    let id: String
    let appearanceDays: [BossStoreAppearanceDay]
    let categories: [Categorizable]
    let distance: Int
    let location: Location?
    let menus: [BossStoreMenu]
    let name: String
    let openingTime: String?
    let imageURL: String?
    let status: OpenStatus
    let snsUrl: String?
    let introduction: String?
    var feedbackCount: Int
    var feedbacks: [BossStoreFeedback]
    var isBookmarked: Bool
    
    init(response: BossStoreAroundInfoResponse) {
        self.id = response.bossStoreId
        self.appearanceDays = []
        self.categories = response.categories.map(FoodTruckCategory.init(response: ))
        self.distance = response.distance
        self.location = Location(response: response.location)
        self.menus = []
        self.name = response.name
        self.openingTime = response.openStatus.openStartDateTime
        self.imageURL = nil
        self.status = OpenStatus(response: response.openStatus.status)
        self.snsUrl = nil
        self.introduction = nil
        self.feedbackCount = response.totalFeedbacksCounts
        self.feedbacks = []
        self.isBookmarked = false
    }
        
    init(response: BossStoreWithFeedbacksResponse) {
        self.id = response.store.bossStoreId
        self.appearanceDays
        = response.store.appearanceDays.map(BossStoreAppearanceDay.init(response:))
        self.categories = response.store.categories.map(FoodTruckCategory.init(response:))
        self.distance = response.store.distance
        self.location = Location(response: response.store.location)
        self.menus = response.store.menus.map(BossStoreMenu.init(response: ))
        self.name = response.store.name
        self.openingTime = response.store.openStatus.openStartDateTime
        self.imageURL = response.store.imageUrl
        self.status = OpenStatus(response: response.store.openStatus.status)
        self.snsUrl = response.store.snsUrl
        self.introduction = response.store.introduction
        self.feedbackCount = response.feedbacks.map { $0.count }.reduce(0, +)
        self.feedbacks = response.feedbacks.map(BossStoreFeedback.init(response:))
        self.isBookmarked = response.store.favorite.isFavorite
    }
    
    init() {
        self.id = ""
        self.appearanceDays = []
        self.categories = []
        self.distance = 0
        self.location = nil
        self.menus = []
        self.name = ""
        self.openingTime = nil
        self.imageURL = nil
        self.status = .open
        self.snsUrl = nil
        self.introduction = nil
        self.feedbackCount = 0
        self.feedbacks = []
        self.isBookmarked = false
    }
}

extension BossStore {
    /// 카테고리들 나열된 문자열
    var categoriesString: String {
        return self.categories.map { "#\($0.name)" }.joined(separator: " ")
    }
}

extension BossStore: StoreProtocol {
    var storeCategory: StoreType {
        return .foodTruck
    }
    
    var latitude: Double {
        return self.location?.latitude ?? 0
    }
    
    var longitude: Double {
        return self.location?.longitude ?? 0
    }
}

extension BossStore: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
