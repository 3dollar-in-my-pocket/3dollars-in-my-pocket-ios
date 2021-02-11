struct Land: Codable {
  let number1: String
  let number2: String
  let name: String?
  let addition0: Addition?
  
  enum CodingKeys: String, CodingKey {
    case number1 = "number1"
    case number2 = "number2"
    case name = "name"
    case addition0 = "addition0"
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    number1 = try values.decodeIfPresent(String.self, forKey: .number1) ?? ""
    number2 = try values.decodeIfPresent(String.self, forKey: .number2) ?? ""
    name = try values.decodeIfPresent(String.self, forKey: .name)
    addition0 = try values.decodeIfPresent(Addition.self, forKey: .addition0)
  }
}
