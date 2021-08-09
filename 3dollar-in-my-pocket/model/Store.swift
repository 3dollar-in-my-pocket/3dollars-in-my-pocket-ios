struct Store: Codable {
  
  let appearanceDays: [WeekDay]
  let categories: [StoreCategory]
  let distance: Int
  let images: [Image]
  let latitude: Double
  let longitude: Double
  let menus: [Menu]
  let paymentMethods: [PaymentType]
  let rating: Float
  var reviews: [Review]
  let storeId: Int
  let storeName: String
  let storeType: StoreType?
  let user: User
  
  
  enum CodingKeys: String, CodingKey {
    case appearanceDays
    case categories
    case distance
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
    case user
  }
  
  
  init(
    category: StoreCategory,
    latitude: Double,
    longitude: Double,
    storeName: String,
    menus: [Menu]
  ) {
    self.appearanceDays = []
    self.categories = [category]
    self.distance = -1
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
    self.user = User()
  }
  
  init(
    id: Int = -1,
    appearanceDays: [WeekDay],
    categories: [StoreCategory],
    latitude: Double,
    longitude: Double,
    menuSections: [MenuSection],
    paymentType: [PaymentType],
    storeName: String,
    storeType: StoreType?
  ) {
    self.appearanceDays = appearanceDays
    self.categories = categories
    self.distance = -1
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
    self.user = User()
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.appearanceDays = try values.decodeIfPresent([WeekDay].self, forKey: .appearanceDays) ?? []
    self.categories = try values.decodeIfPresent([StoreCategory].self, forKey: .categories) ?? []
    self.distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? -1
    self.storeId = try values.decodeIfPresent(Int.self, forKey: .storeId) ?? -1
    self.images = try values.decodeIfPresent([Image].self, forKey: .images) ?? []
    self.latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? -1
    self.longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? -1
    self.menus = try values.decodeIfPresent([Menu].self, forKey: .menus) ?? []
    self.paymentMethods = try values.decodeIfPresent([PaymentType].self, forKey: .paymentMethods) ?? []
    self.rating = try values.decodeIfPresent(Float.self, forKey: .rating) ?? 0
    self.reviews = try values.decodeIfPresent([Review].self, forKey: .reviews) ?? []
    self.storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
    self.storeType = try values.decodeIfPresent(StoreType.self, forKey: .storeType)
    self.user = try values.decodeIfPresent(User.self, forKey: .user) ?? User()
  }
  
  func toJson() -> [String: Any] {
//    {
//      "appearanceDays": [
//        "MONDAY"
//      ],
//      "latitude": 0,
//      "longitude": 0,
//      "menu": [
//        {
//          "category": "BUNGEOPPANG",
//          "name": "",
//          "price": ""
//        },
//        {
//          "category": "KKOCHI",
//          "name": "",
//          "price": ""
//        }
//      ],
//      "paymentMethods": [
//        "CASH"
//      ],
//      "storeName": "string",
//      "storeType": "ROAD"
//    }
    var dictionary: [String: Any] = [
      "appearanceDays": self.appearanceDays.map { $0.rawValue },
      "latitude": self.latitude,
      "longitude": self.longitude,
      
      "categories": self.categories.map { $0.rawValue }.joined(separator: ","),
      
      "paymentMethods": self.paymentMethods.map { $0.rawValue }.joined(separator: ","),
      "storeName": self.storeName
    ]
    
    if let storeType = self.storeType {
      dictionary["storeType"] = storeType.rawValue
    }
    
    return dictionary
  }
}
