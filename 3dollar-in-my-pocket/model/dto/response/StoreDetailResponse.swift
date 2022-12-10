struct StoreDetailResponse: Decodable {
    let appearanceDays: [WeekDay]
    let categories: [StreetFoodStoreCategory]
    let distance: Int
    var favorite: FavoriteStoreResponse
    let images: [StoreImageResponse]
    let latitude: Double
    let longitude: Double
    let menus: [MenuResponse]
    let paymentMethods: [PaymentType]
    let rating: Double
    let reviews: [ReviewWithWriterResponse]
    let storeId: Int
    let storeName: String
    let storeType: StreetFoodStoreType?
    let updatedAt: String?
    let user: UserInfoResponse
    let visitHistories: [VisitHistoryWithUserResponse]
    let visitHistory: VisitHistoryCountsResponse
    
    enum CodingKeys: String, CodingKey {
        case appearanceDays
        case categories
        case distance
        case favorite
        case images
        case latitude
        case longitude
        case menus
        case paymentMethods
        case rating
        case reviews
        case storeId
        case storeName
        case storeType
        case updatedAt
        case user
        case visitHistories
        case visitHistory
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.appearanceDays = try values.decodeIfPresent(
            [WeekDay].self,
            forKey: .appearanceDays
        ) ?? []
        self.categories = try values.decodeIfPresent(
            [StreetFoodStoreCategory].self,
            forKey: .categories
        ) ?? []
        self.distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? 0
        self.favorite = try values.decodeIfPresent(
            FavoriteStoreResponse.self,
            forKey: .favorite
        ) ?? FavoriteStoreResponse(isFavorite: false)
        self.images = try values.decodeIfPresent(
            [StoreImageResponse].self,
            forKey: .images
        ) ?? []
        self.latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
        self.longitude = try values.decodeIfPresent(
            Double.self,
            forKey: .longitude
        ) ?? 0
        self.menus = try values.decodeIfPresent(
            [MenuResponse].self,
            forKey: .menus
        ) ?? []
        self.paymentMethods = try values.decodeIfPresent(
            [PaymentType].self,
            forKey: .paymentMethods
        ) ?? []
        self.rating = try values.decodeIfPresent(Double.self, forKey: .rating) ?? 0
        self.reviews = try values.decodeIfPresent(
            [ReviewWithWriterResponse].self,
            forKey: .reviews
        ) ?? []
        self.storeId = try values.decodeIfPresent(Int.self, forKey: .storeId) ?? 0
        self.storeName = try values.decodeIfPresent(
            String.self,
            forKey: .storeName
        ) ?? ""
        self.storeType = try values.decodeIfPresent(
            StreetFoodStoreType.self,
            forKey: .storeType
        )
        self.updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        self.user = try values.decodeIfPresent(
            UserInfoResponse.self,
            forKey: .user
        ) ?? UserInfoResponse()
        self.visitHistories = try values.decodeIfPresent(
            [VisitHistoryWithUserResponse].self,
            forKey: .visitHistories
        ) ?? []
        self.visitHistory = try values.decodeIfPresent(
            VisitHistoryCountsResponse.self,
            forKey: .visitHistory
        ) ??  VisitHistoryCountsResponse()
    }
}
