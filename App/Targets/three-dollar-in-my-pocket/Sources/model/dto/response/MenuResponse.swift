struct MenuResponse: Decodable {
  
  let category: StreetFoodStoreCategory
  let menuId: Int
  let name: String
  let price: String
  
  enum CodingKeys: String, CodingKey {
    case category
    case menuId
    case name
    case price
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.category = try values.decodeIfPresent(
        StreetFoodStoreCategory.self,
      forKey: .category
    ) ?? .BUNGEOPPANG
    self.menuId = try values.decodeIfPresent(Int.self, forKey: .menuId) ?? 0
    self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    self.price = try values.decodeIfPresent(String.self, forKey: .price) ?? ""
  }
}
