struct LocalResponse<T: Decodable>: Decodable {
  
  let meta: Meta
  let documents: [T]
  
  enum CodingKeys: String, CodingKey {
    case meta
    case documents
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    meta = try values.decodeIfPresent(Meta.self, forKey: .meta) ?? Meta()
    documents = try values.decodeIfPresent([T].self, forKey: .documents) ?? []
  }
}
