struct Menu: Codable {
  let id: Int
  var name: String
  var price: String?
  
  init(name: String, price: String? = nil) {
    self.id = -1
    self.name = name
    self.price = price
  }
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case name = "name"
    case price = "price"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    price = try values.decodeIfPresent(String.self, forKey: .price)
  }
  
  mutating func setPrice(price: String) {
    self.price = price
  }
  
  func toDict() -> [String: Any] {
    return ["name": name, "price": price]
  }
}
