struct Image: Codable {
  let id: Int
  let url: String
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case url = "url"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    url = try values.decodeIfPresent(String.self, forKey: .url) ?? ""
  }
}
