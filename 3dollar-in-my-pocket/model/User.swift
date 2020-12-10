struct User: Codable {
  
  var nickname: String?
  let socialId: String
  let socialType: SocialType
  
  enum CodingKeys: String, CodingKey {
    case nickname = "name"
    case socialId = "socialId"
    case socialType = "socialType"
  }
  
  init(nickname: String? = nil, socialId: String, socialType: String) {
    self.nickname = nickname
    self.socialId = socialId
    self.socialType = SocialType(rawValue: socialType) ?? .KAKAO
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
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
