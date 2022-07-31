struct BossStore: StoreProtocol {
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
    let contacts: String?
    let snsUrl: String?
    let introduction: String?
    let feedbackCount: Int
    
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
        self.contacts = nil
        self.snsUrl = nil
        self.introduction = nil
        self.feedbackCount = response.totalFeedbacksCounts
    }
    
    init(response: BossStoreInfoResponse) {
        self.id = response.bossStoreId
        self.appearanceDays
        = response.appearanceDays.map(BossStoreAppearanceDay.init(response:))
        self.categories = response.categories.map(FoodTruckCategory.init(response:))
        self.distance = response.distance
        self.location = Location(response: response.location)
        self.menus = response.menus.map(BossStoreMenu.init(response: ))
        self.name = response.name
        self.openingTime = response.openStatus.openStartDateTime
        self.imageURL = response.imageUrl
        self.status = OpenStatus(response: response.openStatus.status)
        self.contacts = response.contactsNumber
        self.snsUrl = response.snsUrl
        self.introduction = response.introduction
        self.feedbackCount = 0
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
        self.contacts = nil
        self.snsUrl = nil
        self.introduction = nil
        self.feedbackCount = 0
    }
}

extension BossStore: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
