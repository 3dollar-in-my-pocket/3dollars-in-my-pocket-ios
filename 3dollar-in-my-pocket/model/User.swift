struct User: Codable {
  
  let name: String
  let userId: Int
  let socialType: SocialType
  
  enum CodingKeys: String, CodingKey {
    case name = "name"
    case userId = "userId"
    case socialType = "socialType"
  }
  
  
  init() {
    self.name = ""
    self.userId = -1
    self.socialType = .KAKAO
  }
  
  init(response: UserInfoResponse) {
    self.name = response.name
    self.userId = response.userId
    self.socialType = response.socialType
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    self.userId = try values.decodeIfPresent(Int.self, forKey: .userId) ?? -1
    self.socialType = try values.decodeIfPresent(SocialType.self, forKey: .socialType) ?? .KAKAO
  }
  
  func toDict() -> [String: Any] {
    return [
      "name": self.name,
      "socialType": self.socialType.rawValue
    ]
  }
}
