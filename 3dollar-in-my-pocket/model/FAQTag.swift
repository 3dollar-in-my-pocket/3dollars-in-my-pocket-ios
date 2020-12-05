struct FAQTag: Codable, Hashable {
  
  let id: Int
  let name: String
  let displayOrder: Int
  
  enum CodingKeys: String, CodingKey {
    case id = "id"
    case name = "name"
    case displayOrder = "displayOrder"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    displayOrder = try values.decodeIfPresent(Int.self, forKey: .displayOrder) ?? -1
  }
  
  init(id: Int, name: String, displayOrder: Int) {
    self.id = id
    self.name = name
    self.displayOrder = displayOrder
  }
}
