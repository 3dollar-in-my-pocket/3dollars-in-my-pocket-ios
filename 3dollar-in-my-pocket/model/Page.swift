struct Page<T: Codable>: Codable {
  
  let content: [T]
  let empty: Bool
  let first: Bool
  let last: Bool
  let number: Int
  let numberOfElements: Int
  let size: Int
  let totalElements: Int
  let totalPages: Int
  
  
  enum CodingKeys: String, CodingKey {
    case content = "content"
    case empty = "empty"
    case first = "first"
    case last = "last"
    case number = "number"
    case numberOfElements = "numberOfElements"
    case size = "size"
    case totalElements = "totalElements"
    case totalPages = "totalPages"
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    content = try values.decodeIfPresent([T].self, forKey: .content) ?? []
    empty = try values.decodeIfPresent(Bool.self, forKey: .empty) ?? true
    first = try values.decodeIfPresent(Bool.self, forKey: .first) ?? true
    last = try values.decodeIfPresent(Bool.self, forKey: .last) ?? true
    number = try values.decodeIfPresent(Int.self, forKey: .number) ?? -1
    numberOfElements = try values.decodeIfPresent(Int.self, forKey: .numberOfElements) ?? -1
    size = try values.decodeIfPresent(Int.self, forKey: .size) ?? -1
    totalElements = try values.decodeIfPresent(Int.self, forKey: .totalElements) ?? -1
    totalPages = try values.decodeIfPresent(Int.self, forKey: .totalPages) ?? -1
  }
}
