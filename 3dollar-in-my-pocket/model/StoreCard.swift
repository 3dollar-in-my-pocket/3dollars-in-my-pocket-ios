struct StoreCard: Codable {
  
  let category: StoreCategory
  let categories: [StoreCategory]
  let distance: Int
  let id: Int
  let latitude: Double
  let longitude: Double
  let storeName: String
  let rating: Float
  
  enum CodingKeys: String, CodingKey {
    case category = "category"
    case categories = "categories"
    case distance = "distance"
    case id = "id"
    case latitude = "latitude"
    case longitude = "longitude"
    case storeName = "storeName"
    case rating = "rating"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    category = try values.decodeIfPresent(StoreCategory.self, forKey: .category) ?? .BUNGEOPPANG
    categories = try values.decodeIfPresent([StoreCategory].self, forKey: .categories) ?? []
    distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? -1
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? -1
    longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? -1
    storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
    rating = try values.decodeIfPresent(Float.self, forKey: .rating) ?? 0
  }
}
