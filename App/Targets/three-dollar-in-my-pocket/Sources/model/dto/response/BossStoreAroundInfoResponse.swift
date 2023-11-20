struct BossStoreAroundInfoResponse: Decodable {
    let bossStoreId: String
    let categories: [BossStoreCategoryResponse]
    let createdAt: String
    let distance: Int
    let location: LocationResponse?
    let menus: [BossStoreMenuResponse]
    let name: String
    let openStatus: BossStoreOpenStatusResponse
    let totalFeedbacksCounts: Int
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case bossStoreId
        case categories
        case createdAt
        case distance
        case location
        case menus
        case name
        case openStatus
        case totalFeedbacksCounts
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.bossStoreId = try values.decodeIfPresent(String.self, forKey: .bossStoreId) ?? ""
        self.categories = try values.decodeIfPresent(
            [BossStoreCategoryResponse].self,
            forKey: .categories
        ) ?? []
        self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? 0
        self.location = try values.decodeIfPresent(
            LocationResponse.self,
            forKey: .location
        ) ?? LocationResponse()
        self.menus = try values.decodeIfPresent([BossStoreMenuResponse].self, forKey: .menus) ?? []
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.openStatus = try values.decodeIfPresent(
            BossStoreOpenStatusResponse.self,
            forKey: .openStatus
        ) ?? BossStoreOpenStatusResponse()
        self.totalFeedbacksCounts = try values.decodeIfPresent(Int.self, forKey: .totalFeedbacksCounts) ?? 0
        self.updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
    }
}
