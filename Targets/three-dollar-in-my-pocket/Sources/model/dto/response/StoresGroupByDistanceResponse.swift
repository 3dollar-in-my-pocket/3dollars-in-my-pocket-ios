struct StoresGroupByDistanceResponse: Decodable {
  
  let storeList50: [StoreInfoResponse]
  let storeList100: [StoreInfoResponse]
  let storeList500: [StoreInfoResponse]
  let storeList1000: [StoreInfoResponse]
  let storeListOver1000: [StoreInfoResponse]
  
  enum CodingKeys: String, CodingKey {
    case storeList50
    case storeList100
    case storeList500
    case storeList1000
    case storeListOver1000
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.storeList50 = try values.decodeIfPresent(
      [StoreInfoResponse].self,
      forKey: .storeList50
    ) ?? []
    self.storeList100 = try values.decodeIfPresent(
      [StoreInfoResponse].self,
      forKey: .storeList100
    ) ?? []
    self.storeList500 = try values.decodeIfPresent(
      [StoreInfoResponse].self,
      forKey: .storeList500
    ) ?? []
    self.storeList1000 = try values.decodeIfPresent(
      [StoreInfoResponse].self,
      forKey: .storeList1000
    ) ?? []
    self.storeListOver1000 = try values.decodeIfPresent(
      [StoreInfoResponse].self,
      forKey: .storeListOver1000
    ) ?? []
  }
}
