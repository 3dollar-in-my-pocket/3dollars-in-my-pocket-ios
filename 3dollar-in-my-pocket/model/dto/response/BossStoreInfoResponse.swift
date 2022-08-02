struct BossStoreInfoResponse: Decodable {
    let appearanceDays: [BossStoreAppearanceDayResponse]
    let bossStoreId: String
    let categories: [BossStoreCategoryResponse]
    let contactsNumber: String?
    let distance: Int
    let imageUrl: String?
    let introduction: String?
    let location: LocationResponse
    let menus: [BossStoreMenuResponse]
    let name: String
    let openStatus: BossStoreOpenStatusResponse
    let snsUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case appearanceDays
        case bossStoreId
        case categories
        case contactsNumber
        case distance
        case imageUrl
        case introduction
        case location
        case menus
        case name
        case openStatus
        case snsUrl
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.appearanceDays = try values.decodeIfPresent(
            [BossStoreAppearanceDayResponse].self,
            forKey: .appearanceDays
        ) ?? []
        self.bossStoreId = try values.decodeIfPresent(
            String.self,
            forKey: .bossStoreId
        ) ?? ""
        self.categories = try values.decodeIfPresent(
            [BossStoreCategoryResponse].self,
            forKey: .categories
        ) ?? []
        self.contactsNumber = try values.decodeIfPresent(
            String.self,
            forKey: .contactsNumber
        )
        self.distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? 0
        self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl)
        self.introduction = try values.decodeIfPresent(
            String.self,
            forKey: .introduction
        )
        self.location = try values.decodeIfPresent(
            LocationResponse.self,
            forKey: .location
        ) ?? LocationResponse()
        self.menus = try values.decodeIfPresent(
            [BossStoreMenuResponse].self,
            forKey: .menus
        ) ?? []
        self.name = try values.decodeIfPresent(
            String.self,
            forKey: .name
        ) ?? ""
        self.openStatus = try values.decodeIfPresent(
            BossStoreOpenStatusResponse.self,
            forKey: .openStatus
        ) ?? BossStoreOpenStatusResponse()
        self.snsUrl = try values.decodeIfPresent(String.self, forKey: .snsUrl)
    }
    
    init() {
        self.appearanceDays = []
        self.bossStoreId = ""
        self.categories = []
        self.contactsNumber = nil
        self.distance = 0
        self.imageUrl = nil
        self.introduction = nil
        self.location = LocationResponse()
        self.menus = []
        self.name = ""
        self.openStatus = BossStoreOpenStatusResponse()
        self.snsUrl = nil
    }
}
