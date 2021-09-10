struct FAQResponse: Decodable {
  
  let answer: String
  let category: StoreCategory
  let createdAt: String
  let faqId: Int
  let question: String
  
  enum CodingKeys: String, CodingKey {
    case answer
    case category
    case createdAt
    case faqId
    case question
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.answer = try values.decodeIfPresent(String.self, forKey: .answer) ?? ""
    self.category = try values.decodeIfPresent(StoreCategory.self, forKey: .category) ?? .BUNGEOPPANG
    self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
    self.faqId = try values.decodeIfPresent(Int.self, forKey: .faqId) ?? 0
    self.question = try values.decodeIfPresent(String.self, forKey: .question) ?? ""
  }
}
