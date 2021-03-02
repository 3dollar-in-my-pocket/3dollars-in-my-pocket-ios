struct StoreResponse: Codable {
  
  let categories: [StoreCategory]
  let category: StoreCategory
  let createdAt: String
  let distance: Int
  let id: Int
  let latitude: Double
  let longitude: Double
  let rating: Float
  let storeName: String
  let updatedAt: String
  
  
  
  enum CodingKeys: String, CodingKey {
    case categories = "categories"
    case category = "category"
    case createdAt = "createdAt"
    case distance = "distance"
    case id = "id"
    case latitude = "latitude"
    case longitude = "longitude"
    case rating = "rating"
    case storeName = "storeName"
    case updatedAt = "updatedAt"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    categories = try values.decodeIfPresent([StoreCategory].self, forKey: .categories) ?? []
    category = try values.decodeIfPresent(StoreCategory.self, forKey: .category) ?? .BUNGEOPPANG
    createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
    distance = try values.decodeIfPresent(Int.self, forKey: .distance) ?? -1
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? -1
    longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? -1
    rating = try values.decodeIfPresent(Float.self, forKey: .rating) ?? 0
    storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
    updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
  }
}
