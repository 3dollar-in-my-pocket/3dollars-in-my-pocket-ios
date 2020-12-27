struct Review: Codable {
  
  let category: StoreCategory
  let contents: String
  let id: Int
  let rating: Int
  let user: User
  let storeId: Int
  let storeName: String
  let createdAt: String
  
  
  enum CodingKeys: String, CodingKey {
    case category = "category"
    case contents = "contents"
    case id = "id"
    case rating = "rating"
    case user = "user"
    case storeId = "storeId"
    case storeName = "storeName"
    case createdAt = "createdAt"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    category = try values.decodeIfPresent(StoreCategory.self, forKey: .category) ?? .BUNGEOPPANG
    contents = try values.decodeIfPresent(String.self, forKey: .contents) ?? ""
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    rating = try values.decodeIfPresent(Int.self, forKey: .rating) ?? -1
    user = try values.decodeIfPresent(User.self, forKey: .user) ?? User(socialId: "", socialType: "")
    storeId = try values.decodeIfPresent(Int.self, forKey: .storeId) ?? -1
    storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
    createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
    
  }
  
  init(rating: Int, contents: String) {
    self.category = .BUNGEOPPANG
    self.contents = contents
    self.id = -1
    self.rating = rating
    self.user = User(socialId: "", socialType: "")
    self.storeId = -1
    self.storeName = ""
    self.createdAt = ""
  }
  
  func toJson() -> [String: Any] {
    return [
      "contents" : self.contents,
      "rating" : self.rating
    ]
  }
}
