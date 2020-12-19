struct SaveResponse: Codable {
  
  let storeId: Int
  
  
  enum CodingKeys: String, CodingKey {
    case storeId = "storeId"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    storeId = try values.decodeIfPresent(Int.self, forKey: .storeId) ?? -1
  }
}
