struct SigninResponse: Decodable {
  
  let token: String
  
  enum CodingKeys: String, CodingKey {
    case token
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.token = try values.decodeIfPresent(String.self, forKey: .token) ?? ""
  }
  
  init() {
    self.token = ""
  }
}
