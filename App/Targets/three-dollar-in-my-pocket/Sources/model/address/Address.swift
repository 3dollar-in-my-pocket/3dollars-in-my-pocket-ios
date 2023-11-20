struct Address: Codable {
  
  let addressName: String
  let region1DepthName: String
  let region2DepthName: String
  let region3DepthName: String
  let region3DepthHName: String
  let hCode: String
  let bCode: String
  let mountainYn: String
  let mainAddressNo: String
  let subAddressNo: String
  let x: String
  let y: String
  
  enum CodingKeys: String, CodingKey {
    case addressName = "address_name"
    case region1DepthName = "region_1depth_name"
    case region2DepthName = "region_2depth_name"
    case region3DepthName = "region_3depth_name"
    case region3DepthHName = "region_3depth_h_name"
    case hCode = "h_code"
    case bCode = "b_code"
    case mountainYn = "mountain_yn"
    case mainAddressNo = "main_address_no"
    case subAddressNo = "sub_address_no"
    case x, y
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    addressName = try values.decodeIfPresent(String.self, forKey: .addressName) ?? ""
    region1DepthName = try values.decodeIfPresent(String.self, forKey: .region1DepthName) ?? ""
    region2DepthName = try values.decodeIfPresent(String.self, forKey: .region2DepthName) ?? ""
    region3DepthName = try values.decodeIfPresent(String.self, forKey: .region3DepthName) ?? ""
    region3DepthHName = try values.decodeIfPresent(String.self, forKey: .region3DepthHName) ?? ""
    hCode = try values.decodeIfPresent(String.self, forKey: .hCode) ?? ""
    bCode = try values.decodeIfPresent(String.self, forKey: .bCode) ?? ""
    mountainYn = try values.decodeIfPresent(String.self, forKey: .mountainYn) ?? ""
    mainAddressNo = try values.decodeIfPresent(String.self, forKey: .mainAddressNo) ?? ""
    subAddressNo = try values.decodeIfPresent(String.self, forKey: .subAddressNo) ?? ""
    y = try values.decodeIfPresent(String.self, forKey: .y) ?? ""
    x = try values.decodeIfPresent(String.self, forKey: .x) ?? ""
  }
  
  init() {
    self.addressName = ""
    self.region1DepthName = ""
    self.region2DepthName = ""
    self.region3DepthName = ""
    self.region3DepthHName = ""
    self.hCode = ""
    self.bCode = ""
    self.mountainYn = ""
    self.mainAddressNo = ""
    self.subAddressNo = ""
    self.y = ""
    self.x = ""
  }
}
