struct StoreInfoResponse: Decodable {
    
    let categories: [StreetFoodStoreCategory]
    let createdAt: String
    let isDeleted: Bool
    let latitude: Double
    let longitude: Double
    let rating: Double
    let storeId: Int
    let storeName: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case categories
        case createdAt
        case isDeleted
        case latitude
        case longitude
        case rating
        case storeId
        case storeName
        case updatedAt
    }
    
    init() {
        self.categories = []
        self.createdAt = ""
        self.isDeleted = false
        self.latitude = 0
        self.longitude = 0
        self.rating = 0
        self.storeId = 0
        self.storeName = ""
        self.updatedAt = ""
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.categories = try values.decodeIfPresent([StreetFoodStoreCategory].self, forKey: .categories) ?? []
        self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.isDeleted = try values.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
        self.latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        self.longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
        self.rating = try values.decodeIfPresent(Double.self, forKey: .rating) ?? 0
        self.storeId = try values.decodeIfPresent(Int.self, forKey: .storeId) ?? 0
        self.storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
        self.updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
    }
    
//    init(store: Store) {
//        self.categories = store.categories
//        self.distance = store.distance
//        self.latitude = store.latitude
//        self.longitude = store.longitude
//        self.rating = Double(store.rating)
//        self.storeId = store.storeId
//        self.storeName = store.storeName
//        self.visitHistory = VisitHistoryInfoResponse()
//    }
//    
//    init(storeCard: StoreCard) {
//        self.categories = storeCard.categories
//        self.distance = storeCard.distance
//        self.latitude = storeCard.latitude
//        self.longitude = storeCard.longitude
//        self.rating = Double(storeCard.rating)
//        self.storeId = storeCard.id
//        self.storeName = storeCard.storeName
//        self.visitHistory = VisitHistoryInfoResponse()
//    }
}
