struct ReviewWithWriterResponse: Decodable {
  
  let contents: String
  let createdAt: String
  let rating: Int
  let reviewId: Int
  let user: UserInfoResponse
  
  enum CodingKeys: String, CodingKey {
    case contents
    case createdAt
    case rating
    case reviewId
    case user
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.contents = try values.decodeIfPresent(String.self, forKey: .contents) ?? ""
    self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
    self.rating = try values.decodeIfPresent(Int.self, forKey: .rating) ?? -1
    self.reviewId = try values.decodeIfPresent(Int.self, forKey: .reviewId) ?? -1
    self.user = try values.decodeIfPresent(
      UserInfoResponse.self,
      forKey: .user
    ) ?? UserInfoResponse()
  }
}
