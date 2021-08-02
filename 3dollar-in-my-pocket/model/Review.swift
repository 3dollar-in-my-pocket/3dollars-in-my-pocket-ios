struct Review: Codable {
  
  let category: StoreCategory
  var contents: String
  let createdAt: String
  let id: Int
  var rating: Int
  let storeId: Int
  let storeName: String
  let user: User
  
  
  enum CodingKeys: String, CodingKey {
    case category = "category"
    case contents = "contents"
    case createdAt = "createdAt"
    case id = "id"
    case rating = "rating"
    case storeId = "storeId"
    case storeName = "storeName"
    case user = "user"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.category = try values.decodeIfPresent(StoreCategory.self, forKey: .category) ?? .BUNGEOPPANG
    self.contents = try values.decodeIfPresent(String.self, forKey: .contents) ?? ""
    self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
    self.id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    self.rating = try values.decodeIfPresent(Int.self, forKey: .rating) ?? -1
    self.storeId = try values.decodeIfPresent(Int.self, forKey: .storeId) ?? -1
    self.storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
    self.user = try values.decodeIfPresent(User.self, forKey: .user) ?? User()
  }
  
  init(rating: Int, contents: String) {
    self.category = .BUNGEOPPANG
    self.contents = contents
    self.createdAt = ""
    self.id = -1
    self.rating = rating
    self.storeId = -1
    self.storeName = ""
    self.user = User()
  }
  
  func toJson() -> [String: Any] {
    return [
      "contents" : self.contents,
      "rating" : self.rating
    ]
  }
}
