struct FAQ: Codable {
  let answer: String
  let id: Int
  let question: String
  let tags: [FAQTag]
  
  enum CodingKeys: String, CodingKey {
    case answer = "answer"
    case id = "id"
    case question = "question"
    case tags = "tags"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    answer = try values.decodeIfPresent(String.self, forKey: .answer) ?? ""
    id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
    question = try values.decodeIfPresent(String.self, forKey: .question) ?? ""
    tags = try values.decodeIfPresent([FAQTag].self, forKey: .tags) ?? []
  }
}
