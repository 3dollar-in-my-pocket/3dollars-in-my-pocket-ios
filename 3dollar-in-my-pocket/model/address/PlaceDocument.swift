struct PlaceDocument: Decodable, Document {
  
  let addressName: String
  let y: String
  let x: String
  let roadAddressName: String
  let placeName: String
  
  enum CodingKeys: String, CodingKey {
    case addressName = "address_name"
    case y, x
    case placeName = "place_name"
    case roadAddressName = "road_address_name"
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    addressName = try values.decodeIfPresent(String.self, forKey: .addressName) ?? ""
    y = try values.decodeIfPresent(String.self, forKey: .y) ?? ""
    x = try values.decodeIfPresent(String.self, forKey: .x) ?? ""
    placeName = try values.decodeIfPresent(String.self, forKey: .placeName) ?? ""
    roadAddressName = try values.decodeIfPresent(String.self, forKey: .roadAddressName) ?? ""
  }
  
  init() {
    self.addressName = ""
    self.x = ""
    self.y = ""
    self.roadAddressName = ""
    self.placeName = ""
  }
}
