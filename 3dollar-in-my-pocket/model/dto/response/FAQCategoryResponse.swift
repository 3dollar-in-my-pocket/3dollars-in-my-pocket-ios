struct FAQCategoryResponse: Decodable {
  let category: FAQCategory
  let description: String
  let displayOrder: Int
  
  enum CodingKeys: String, CodingKey {
    case category
    case description
    case displayOrder
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.category = try values.decodeIfPresent(FAQCategory.self, forKey: .category) ?? .CATEGORY
    self.description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
    self.displayOrder = try values.decodeIfPresent(Int.self, forKey: .displayOrder) ?? 0
  }
}
