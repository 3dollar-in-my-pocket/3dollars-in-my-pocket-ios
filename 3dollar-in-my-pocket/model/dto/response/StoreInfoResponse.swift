struct StoreInfoResponse: Decodable {
  
  let categories: [StoreCategory]
  let distance: Int
  let latitude: Double
  let longitude: Double
  let rating: Double
  let storeId: Int
  let storeName: String
  
  
  enum CodingKeys: String, CodingKey {
    case categories
    case distance
    case latitude
    case longitude
    case rating
    case storeId
    case storeName
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.categories = try values.decodeIfPresent([StoreCategory].self, forKey: .categories) ?? []
    self.distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? 0
    self.latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? 0
    self.longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? 0
    self.rating = try values.decodeIfPresent(Double.self, forKey: .rating) ?? 0
    self.storeId = try values.decodeIfPresent(Int.self, forKey: .storeId) ?? 0
    self.storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
  }
  
  init(store: Store) {
    self.categories = store.categories
    self.distance = store.distance
    self.latitude = store.latitude
    self.longitude = store.longitude
    self.rating = Double(store.rating)
    self.storeId = store.id
    self.storeName = store.storeName
  }
}
