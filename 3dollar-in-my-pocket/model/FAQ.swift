struct FAQ: Decodable {
  let answer: String
  let id: Int
  let question: String
  let category: FAQCategory
  
  enum CodingKeys: String, CodingKey {
    case answer
    case id
    case question
    case category
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    answer = try values.decodeIfPresent(String.self, forKey: .answer) ?? ""
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    question = try values.decodeIfPresent(String.self, forKey: .question) ?? ""
    category = try values.decodeIfPresent(FAQCategory.self, forKey: .category) ?? .store
  }
  
  init(response: FAQResponse) {
    self.answer = response.answer
    self.id = response.faqId
    self.question = response.question
    self.category = response.category
  }
}
