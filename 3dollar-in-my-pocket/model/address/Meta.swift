struct Meta: Codable {
  
  let totalCount: Int
  let pageableCount: Int
  let isEnd: Bool
  
  enum CodingKeys: String, CodingKey {
    case totalCount = "total_count"
    case pageableCount = "pageable_count"
    case isEnd = "is_end"
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    totalCount = try values.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
    pageableCount = try values.decodeIfPresent(Int.self, forKey: .pageableCount) ?? 0
    isEnd = try values.decodeIfPresent(Bool.self, forKey: .isEnd) ?? true
  }
  
  init() {
    self.totalCount = 0
    self.pageableCount = 0
    self.isEnd = true
  }
}
