struct RoadAddress: Decodable {
  
  let addressName: String
  let region1DepthName: String
  let region2DepthName: String
  let region3DepthName: String
  let roadName: String
  let undergroundYn: String
  let mainBuildingNo: String
  let subBuildingNo: String
  let buildingName: String
  let zoneNo: String
  let y: String
  let x: String
  
  enum CodingKeys: String, CodingKey {
    case addressName = "address_name"
    case region1DepthName = "region_1depth_name"
    case region2DepthName = "region_2depth_name"
    case region3DepthName = "region_3depth_name"
    case roadName = "road_name"
    case undergroundYn = "underground_yn"
    case mainBuildingNo = "main_building_no"
    case subBuildingNo = "sub_building_no"
    case buildingName = "building_name"
    case zoneNo = "zone_no"
    case y, x
  }
  
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    addressName = try values.decodeIfPresent(String.self, forKey: .addressName) ?? ""
    region1DepthName = try values.decodeIfPresent(String.self, forKey: .region1DepthName) ?? ""
    region2DepthName = try values.decodeIfPresent(String.self, forKey: .region2DepthName) ?? ""
    region3DepthName = try values.decodeIfPresent(String.self, forKey: .region3DepthName) ?? ""
    roadName = try values.decodeIfPresent(String.self, forKey: .roadName) ?? ""
    undergroundYn = try values.decodeIfPresent(String.self, forKey: .undergroundYn) ?? ""
    mainBuildingNo = try values.decodeIfPresent(String.self, forKey: .mainBuildingNo) ?? ""
    subBuildingNo = try values.decodeIfPresent(String.self, forKey: .subBuildingNo) ?? ""
    buildingName = try values.decodeIfPresent(String.self, forKey: .buildingName) ?? ""
    zoneNo = try values.decodeIfPresent(String.self, forKey: .zoneNo) ?? ""
    y = try values.decodeIfPresent(String.self, forKey: .y) ?? ""
    x = try values.decodeIfPresent(String.self, forKey: .x) ?? ""
  }
  
  init() {
    self.addressName = ""
    self.region1DepthName = ""
    self.region2DepthName = ""
    self.region3DepthName = ""
    self.roadName = ""
    self.undergroundYn = ""
    self.mainBuildingNo = ""
    self.subBuildingNo = ""
    self.buildingName = ""
    self.zoneNo = ""
    self.y = ""
    self.x = ""
  }
}
