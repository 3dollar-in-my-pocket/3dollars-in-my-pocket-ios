struct StoreDeleteResponse: Decodable {
  let isDeleted: Bool
  
  enum CodingKeys: String, CodingKey {
    case isDeleted
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.isDeleted = try values.decodeIfPresent(Bool.self, forKey: .isDeleted) ?? false
  }
}
