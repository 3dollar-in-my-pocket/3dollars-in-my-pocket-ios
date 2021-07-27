struct SigninResponse: Decodable {
  
  let sessionId: String
  
  enum CodingKeys: String, CodingKey {
    case sessionId
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.sessionId = try values.decodeIfPresent(String.self, forKey: .sessionId) ?? ""
  }
}
