struct StoresGroupByReviewResponse: Decodable {
  
  let storeList0: [StoreInfoResponse]
  let storeList1: [StoreInfoResponse]
  let storeList2: [StoreInfoResponse]
  let storeList3: [StoreInfoResponse]
  let storeList4: [StoreInfoResponse]
  
  enum CodingKeys: String, CodingKey {
    case storeList0
    case storeList1
    case storeList2
    case storeList3
    case storeList4
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    self.storeList0 = try values.decodeIfPresent(
      [StoreInfoResponse].self,
      forKey: .storeList0
    ) ?? []
    self.storeList1 = try values.decodeIfPresent(
      [StoreInfoResponse].self,
      forKey: .storeList1
    ) ?? []
    self.storeList2 = try values.decodeIfPresent(
      [StoreInfoResponse].self,
      forKey: .storeList2
    ) ?? []
    self.storeList3 = try values.decodeIfPresent(
      [StoreInfoResponse].self,
      forKey: .storeList3
    ) ?? []
    self.storeList4 = try values.decodeIfPresent(
      [StoreInfoResponse].self,
      forKey: .storeList4
    ) ?? []
  }
}
