struct UserInfoResponse: Decodable {
  
  let name: String
  let socialType: SocialType
  let userId: Int
  
  enum CodingKeys: String, CodingKey {
    case name
    case socialType
    case userId
  }
  
  
  init() {
    self.name = ""
    self.socialType = .KAKAO
    self.userId = -1
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    self.socialType = try values.decodeIfPresent(SocialType.self, forKey: .socialType) ?? .KAKAO
    self.userId = try values.decodeIfPresent(Int.self, forKey: .userId) ?? -1
  }
}
