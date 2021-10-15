struct StoreImageResponse: Decodable {
  
  let imageId: Int
  let url: String
  
  enum CodingKeys: String, CodingKey {
    case imageId
    case url
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.imageId = try values.decodeIfPresent(Int.self, forKey: .imageId) ?? -1
    self.url = try values.decodeIfPresent(String.self, forKey: .url) ?? ""
  }
}
