struct Addition: Codable {
  let value: String
  
  enum CodingKeys: String, CodingKey {
    case value = "value"
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    value = try values.decodeIfPresent(String.self, forKey: .value) ?? ""
  }
}
