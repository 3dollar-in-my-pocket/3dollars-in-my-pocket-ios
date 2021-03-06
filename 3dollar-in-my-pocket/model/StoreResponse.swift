struct StoreResponse: Codable {
  
  let categories: [StoreCategory]
  let category: StoreCategory
  let distance: Int
  let id: Int
  let latitude: Double
  let longitude: Double
  let rating: Float
  let storeName: String
  
  
  
  enum CodingKeys: String, CodingKey {
    case categories = "categories"
    case category = "category"
    case distance = "distance"
    case id = "id"
    case latitude = "latitude"
    case longitude = "longitude"
    case rating = "rating"
    case storeName = "storeName"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    categories = try values.decodeIfPresent([StoreCategory].self, forKey: .categories) ?? []
    category = try values.decodeIfPresent(StoreCategory.self, forKey: .category) ?? .BUNGEOPPANG
    distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? -1
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? -1
    longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? -1
    rating = try values.decodeIfPresent(Float.self, forKey: .rating) ?? 0
    storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
  }
  
  init(store: Store) {
    self.category = store.category
    self.categories = store.categories
    self.distance = store.distance
    self.id = store.id
    self.latitude = store.latitude
    self.longitude = store.longitude
    self.rating = store.rating
    self.storeName = store.storeName
  }
}
