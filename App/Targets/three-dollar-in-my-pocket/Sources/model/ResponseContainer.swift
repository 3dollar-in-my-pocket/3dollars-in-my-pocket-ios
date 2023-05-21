struct ResponseContainer<T: Decodable>: Decodable {
  
  let data: T?
  let message: String
  let resultCode: String
  
  enum CodingKeys: String, CodingKey {
    case data
    case message
    case resultCode
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.data = try values.decodeIfPresent(T.self, forKey: .data)
    self.message = try values.decodeIfPresent(String.self, forKey: .message) ?? ""
    self.resultCode = try values.decodeIfPresent(String.self, forKey: .resultCode) ?? ""
  }
}
