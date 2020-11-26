import ObjectMapper

struct User: Mappable, Codable {
  
  var nickname: String?
  var socialId: String!
  var socialType: SocialType!
  
  init?(map: Map) {}
  
  init(nickname: String? = nil, socialId: String, socialType: String) {
    self.nickname = nickname
    self.socialId = socialId
    self.socialType = SocialType.init(rawValue: socialType)
  }
  
  mutating func mapping(map: Map) {
    self.nickname <- map["name"]
    self.socialId <- map["socialId"]
    self.socialType <- map["socialType"]
  }
  
  func toDict() -> [String: Any] {
    return ["name": self.nickname,
            "socialId": self.socialId,
            "socialType": self.socialType.rawValue]
  }
  
  enum CodingKeys: String, CodingKey {
    case nickname = "name"
    case socialId = "socialId"
    case socialType = "socialType"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    nickname = try values.decodeIfPresent(String.self, forKey: .nickname)
    socialId = try values.decodeIfPresent(String.self, forKey: .socialId) ?? ""
    socialType = try values.decodeIfPresent(SocialType.self, forKey: .socialType) ?? .KAKAO
  }
}

enum SocialType: String, Codable {
  case KAKAO = "KAKAO"
  case APPLE = "APPLE"
}
