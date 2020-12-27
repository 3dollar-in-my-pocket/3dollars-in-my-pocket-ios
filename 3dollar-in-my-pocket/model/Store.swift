struct Store: Codable {
  
  let category: StoreCategory
  let id: Int
  let images: [Image]
  let latitude: Double
  let longitude: Double
  let menus: [Menu]
  let rating: Float
  var reviews: [Review]
  let storeName: String
  let repoter: User
  let distance: Int
  
  enum CodingKeys: String, CodingKey {
    case category = "category"
    case id = "id"
    case images = "image"
    case latitude = "latitude"
    case longitude = "longitude"
    case menus = "menu"
    case rating = "rating"
    case reviews = "review"
    case storeName = "storeName"
    case repoter = "user"
    case distance = "distance"
  }
  
  
  init(
    category: StoreCategory,
    latitude: Double,
    longitude: Double,
    storeName: String,
    menus: [Menu]
  ) {
    self.category = category
    self.id = -1
    self.images = []
    self.latitude = latitude
    self.longitude = longitude
    self.menus = menus
    self.rating = -1
    self.reviews = []
    self.storeName = storeName
    self.repoter = User(socialId: "", socialType: "")
    self.distance = -1
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    category = try values.decodeIfPresent(StoreCategory.self, forKey: .category) ?? .BUNGEOPPANG
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    images = try values.decodeIfPresent([Image].self, forKey: .images) ?? []
    latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? -1
    longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? -1
    menus = try values.decodeIfPresent([Menu].self, forKey: .menus) ?? []
    rating = try values.decodeIfPresent(Float.self, forKey: .rating) ?? -1
    reviews = try values.decodeIfPresent([Review].self, forKey: .reviews) ?? []
    storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
    repoter = try values.decodeIfPresent(User.self, forKey: .repoter) ?? User(socialId: "", socialType: "")
    distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? -1
  }
  
  func toJson() -> [String: Any] {
    return [
      "category" : self.category.getValue(),
      "latitude" : self.latitude,
      "longitude" : self.longitude,
      "storeName" : self.storeName
    ]
  }
}
