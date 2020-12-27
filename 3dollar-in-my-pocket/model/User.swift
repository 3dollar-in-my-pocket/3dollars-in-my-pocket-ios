struct User: Codable {
  
  let id: Int
  var nickname: String?
  let socialId: String
  let socialType: SocialType
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case nickname = "name"
    case socialId = "socialId"
    case socialType = "socialType"
  }
  
  init(nickname: String? = nil, socialId: String, socialType: String) {
    self.id = -1
    self.nickname = nickname
    self.socialId = socialId
    self.socialType = SocialType(rawValue: socialType) ?? .KAKAO
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    nickname = try values.decodeIfPresent(String.self, forKey: .nickname)
    socialId = try values.decodeIfPresent(String.self, forKey: .socialId) ?? ""
    socialType = try values.decodeIfPresent(SocialType.self, forKey: .socialType) ?? .KAKAO
  }
  
  func toDict() -> [String: Any] {
    return [
      "name": self.nickname ?? "",
      "socialId": self.socialId,
      "socialType": self.socialType.rawValue
    ]
  }
}
