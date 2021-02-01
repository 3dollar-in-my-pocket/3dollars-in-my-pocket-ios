struct Store: Codable {
  
  let appearanceDays: [WeekDay]
  let category: StoreCategory
  let distance: Int
  let id: Int
  let images: [Image]
  let latitude: Double
  let longitude: Double
  let menus: [Menu]
  let paymentMethods: [PaymentType]
  let rating: Float
  var reviews: [Review]
  let storeName: String
  let storeType: StoreType?
  let repoter: User
  
  
  enum CodingKeys: String, CodingKey {
    case appearanceDays = "appearanceDays"
    case category = "category"
    case distance = "distance"
    case id = "id"
    case images = "image"
    case latitude = "latitude"
    case longitude = "longitude"
    case menus = "menu"
    case paymentMethods = "paymentMethods"
    case rating = "rating"
    case reviews = "review"
    case storeName = "storeName"
    case storeType = "storeType"
    case repoter = "user"
  }
  
  
  init(
    category: StoreCategory,
    latitude: Double,
    longitude: Double,
    storeName: String,
    menus: [Menu]
  ) {
    self.appearanceDays = []
    self.category = category
    self.distance = -1
    self.id = -1
    self.images = []
    self.latitude = latitude
    self.longitude = longitude
    self.menus = menus
    self.paymentMethods = []
    self.rating = -1
    self.reviews = []
    self.storeName = storeName
    self.storeType = nil
    self.repoter = User(socialId: "", socialType: "")
  }
  
  init(
    appearanceDays: [WeekDay],
    latitude: Double,
    longitude: Double,
    menuSections: [MenuSection],
    paymentType: [PaymentType],
    storeName: String,
    storeType: StoreType
  ) {
    self.appearanceDays = appearanceDays
    self.category = .BUNGEOPPANG
    self.distance = -1
    self.id = -1
    self.images = []
    self.latitude = latitude
    self.longitude = longitude
    
    var menus: [Menu] = []
    for menuSection in menuSections {
      menus = menus + menuSection.toMenu()
    }
    self.menus = menus
    self.paymentMethods = paymentType
    self.rating = -1
    self.reviews = []
    self.storeName = storeName
    self.storeType = storeType
    self.repoter = User(socialId: "", socialType: "")
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.appearanceDays = try values.decodeIfPresent([WeekDay].self, forKey: .appearanceDays) ?? []
    self.category = try values.decodeIfPresent(StoreCategory.self, forKey: .category) ?? .BUNGEOPPANG
    self.distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? -1
    self.id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    self.images = try values.decodeIfPresent([Image].self, forKey: .images) ?? []
    self.latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? -1
    self.longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? -1
    self.menus = try values.decodeIfPresent([Menu].self, forKey: .menus) ?? []
    self.paymentMethods = try values.decodeIfPresent([PaymentType].self, forKey: .paymentMethods) ?? []
    self.rating = try values.decodeIfPresent(Float.self, forKey: .rating) ?? -1
    self.reviews = try values.decodeIfPresent([Review].self, forKey: .reviews) ?? []
    self.storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
    self.storeType = try values.decodeIfPresent(StoreType.self, forKey: .storeType)
    self.repoter = try values.decodeIfPresent(User.self, forKey: .repoter) ?? User(socialId: "", socialType: "")
  }
  
  func toJson() -> [String: Any] {
    return [
      "appearanceDays": self.appearanceDays.map { $0.rawValue },
//      "category" : self.category.getValue(),
      "latitude": self.latitude,
      "longitude": self.longitude,
      "paymentMethods": self.paymentMethods.map { $0.rawValue },
      "storeName": self.storeName,
      "storeType": self.storeType?.rawValue ?? StoreType.road.rawValue
    ]
  }
}
