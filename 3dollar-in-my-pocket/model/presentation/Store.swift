struct Store: StoreProtocol {
    var id: String {
        return String(self.storeId)
    }
    
    let appearanceDays: [WeekDay]
    let categories: [StreetFoodStoreCategory]
    let isDeleted: Bool
    let distance: Int
    var images: [Image]
    let latitude: Double
    let longitude: Double
    let menus: [Menu]
    let paymentMethods: [PaymentType]
    let rating: Double
    var reviews: [Review]
    let storeId: Int
    let storeName: String
    let storeType: StreetFoodStoreType?
    let updatedAt: String?
    let user: User
    let visitHistories: [VisitHistory]
    var visitHistory: VisitOverview
    
    init(
        category: StreetFoodStoreCategory,
        latitude: Double,
        longitude: Double,
        storeName: String,
        menus: [Menu]
    ) {
        self.appearanceDays = []
        self.categories = [category]
        self.distance = -1
        self.isDeleted = false
        self.storeId = -1
        self.images = []
        self.latitude = latitude
        self.longitude = longitude
        self.menus = menus
        self.paymentMethods = []
        self.rating = -1
        self.reviews = []
        self.storeName = storeName
        self.storeType = nil
        self.updatedAt = nil
        self.user = User()
        self.visitHistories = []
        self.visitHistory = VisitOverview()
    }
    
    init(
        id: Int = -1,
        appearanceDays: [WeekDay],
        categories: [StreetFoodStoreCategory],
        latitude: Double,
        longitude: Double,
        menuSections: [MenuSection],
        paymentType: [PaymentType],
        storeName: String,
        storeType: StreetFoodStoreType?
    ) {
        self.appearanceDays = appearanceDays
        self.categories = categories
        self.distance = -1
        self.isDeleted = false
        self.storeId = id
        self.images = []
        self.latitude = latitude
        self.longitude = longitude
        
        var menus: [Menu] = []
        for menuSection in menuSections {
            menus += menuSection.toMenu()
        }
        self.menus = menus
        self.paymentMethods = paymentType
        self.rating = -1
        self.reviews = []
        self.storeName = storeName
        self.storeType = storeType
        self.updatedAt = nil
        self.user = User()
        self.visitHistories = []
        self.visitHistory = VisitOverview()
    }
    
    init() {
        self.appearanceDays = []
        self.categories = []
        self.isDeleted = false
        self.distance = 0
        self.storeId = 0
        self.images = []
        self.latitude = 0
        self.longitude = 0
        self.menus = []
        self.paymentMethods = []
        self.rating = 0
        self.reviews = []
        self.storeName = ""
        self.storeType = nil
        self.updatedAt = nil
        self.user = User()
        self.visitHistories = []
        self.visitHistory = VisitOverview()
    }
    
    init(response: StoreInfoResponse) {
        self.appearanceDays = []
        self.categories = response.categories
        self.distance = 0
        self.isDeleted = response.isDeleted
        self.storeId = response.storeId
        self.images = []
        self.latitude = response.latitude
        self.longitude = response.longitude
        self.menus = []
        self.paymentMethods = []
        self.rating = response.rating
        self.reviews = []
        self.storeName = response.storeName
        self.storeType = nil
        self.updatedAt = nil
        self.user = User()
        self.visitHistories = []
        self.visitHistory = VisitOverview()
    }
    
    init(response: StoreDetailResponse) {
        self.appearanceDays = response.appearanceDays
        self.categories = response.categories
        self.distance = response.distance
        self.isDeleted = false
        self.storeId = response.storeId
        self.images = response.images.map(Image.init)
        self.latitude = response.latitude
        self.longitude = response.longitude
        self.menus = response.menus.map(Menu.init)
        self.paymentMethods = response.paymentMethods
        self.rating = response.rating
        self.reviews = response.reviews.map(Review.init)
        self.storeName = response.storeName
        self.storeType = response.storeType
        self.updatedAt = response.updatedAt
        self.user = User(response: response.user)
        self.visitHistories = response.visitHistories.map { VisitHistory(response: $0) }
        self.visitHistory = VisitOverview(response: response.visitHistory)
    }
    
    init(response: StoreWithVisitsResponse) {
        self.appearanceDays = []
        self.categories = response.categories
        self.distance = 0
        self.isDeleted = response.isDeleted
        self.storeId = response.storeId
        self.images = []
        self.latitude = response.latitude
        self.longitude = response.longitude
        self.menus = []
        self.paymentMethods = []
        self.rating = response.rating
        self.reviews = []
        self.storeName = response.storeName
        self.storeType = nil
        self.updatedAt = response.updatedAt
        self.user = User()
        self.visitHistories = []
        self.visitHistory = VisitOverview(response: response.visitHistory)
    }
    
    init(response: StoreWithVisitsAndDistanceResponse) {
        self.appearanceDays = []
        self.categories = response.categories
        self.distance = response.distance
        self.isDeleted = response.isDeleted
        self.storeId = response.storeId
        self.images = []
        self.latitude = response.latitude
        self.longitude = response.longitude
        self.menus = []
        self.paymentMethods = []
        self.rating = response.rating
        self.reviews = []
        self.storeName = response.storeName
        self.storeType = nil
        self.updatedAt = response.updatedAt
        self.user = User()
        self.visitHistories = []
        self.visitHistory = VisitOverview(response: response.visitHistory)
    }
}

extension Store {
    /// 카테고리들 나열된 문자열 ex.) #붕어빵 #땅콩과자 #호떡
    var categoriesString: String {
        return self.categories.map { "#\($0.name)"}.joined(separator: " ")
    }
}

extension Store: Equatable {
    static func == (lhs: Store, rhs: Store) -> Bool {
        return lhs.storeId == rhs.storeId
    }
}
