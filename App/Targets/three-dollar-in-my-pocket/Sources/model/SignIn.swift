struct SignIn: Codable {
  
  var token: String
  var id: Int
  var state: Bool // 닉네임까지 입력해서 완벽하게 가입했는지 판별하는 플래그
  
  enum CodingKeys: String, CodingKey {
    case token = "token"
    case id = "userId"
    case state = "state"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    token = try values.decodeIfPresent(String.self, forKey: .token) ?? ""
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    state = try values.decodeIfPresent(Bool.self, forKey: .state) ?? false
  }
}
