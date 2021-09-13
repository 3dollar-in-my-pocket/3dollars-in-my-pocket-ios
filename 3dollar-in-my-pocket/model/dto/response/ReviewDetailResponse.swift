struct ReviewDetailResponse: Decodable {
  
  let categories: [StoreCategory]
  let contents: String
  let createdAt: String
  let rating: Int
  let reviewId: Int
  let storeId: Int
  let storeName: String
  let user: UserInfoResponse
  
  enum CodingKeys: String, CodingKey {
    case categories
    case contents
    case createdAt
    case rating
    case reviewId
    case storeId
    case storeName
    case user
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.categories = try values.decodeIfPresent([StoreCategory].self, forKey: .categories) ?? []
    self.contents = try values.decodeIfPresent(String.self, forKey: .contents) ?? ""
    self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
    self.rating = try values.decodeIfPresent(Int.self, forKey: .rating) ?? 0
    self.reviewId = try values.decodeIfPresent(Int.self, forKey: .reviewId) ?? -1
    self.storeId = try values.decodeIfPresent(Int.self, forKey: .storeId) ?? -1
    self.storeName = try values.decodeIfPresent(String.self, forKey: .storeName) ?? ""
    self.user = try values.decodeIfPresent(UserInfoResponse.self, forKey: .user) ?? UserInfoResponse()
  }
}
