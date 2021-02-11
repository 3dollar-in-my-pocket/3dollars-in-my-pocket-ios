struct Region: Codable {
  let area0: Area
  let area1: Area
  let area2: Area
  let area3: Area
  let area4: Area
  
  enum CodingKeys: String, CodingKey {
    case area0 = "area0"
    case area1 = "area1"
    case area2 = "area2"
    case area3 = "area3"
    case area4 = "area4"
  }
  
  init() {
    self.area0 = Area()
    self.area1 = Area()
    self.area2 = Area()
    self.area3 = Area()
    self.area4 = Area()
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    area0 = try values.decodeIfPresent(Area.self, forKey: .area0) ?? Area()
    area1 = try values.decodeIfPresent(Area.self, forKey: .area1) ?? Area()
    area2 = try values.decodeIfPresent(Area.self, forKey: .area2) ?? Area()
    area3 = try values.decodeIfPresent(Area.self, forKey: .area3) ?? Area()
    area4 = try values.decodeIfPresent(Area.self, forKey: .area4) ?? Area()
  }
}
