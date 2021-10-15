struct SigninResponse: Decodable {
  
  let token: String
  let userId: Int
  
  enum CodingKeys: String, CodingKey {
    case token
    case userId
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.token = try values.decodeIfPresent(String.self, forKey: .token) ?? ""
    self.userId = try values.decodeIfPresent(Int.self, forKey: .userId) ?? 0
  }
  
  init() {
    self.token = ""
    self.userId = 0
  }
}
