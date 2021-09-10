struct CategoryByReview: Codable {
  
  let storeList0: [StoreCard]
  let storeList1: [StoreCard]
  let storeList2: [StoreCard]
  let storeList3: [StoreCard]
  let storeList4: [StoreCard]
  var indexList: [Int] = []
  
  enum CodingKeys: String, CodingKey {
    case storeList0 = "storeList0"
    case storeList1 = "storeList1"
    case storeList2 = "storeList2"
    case storeList3 = "storeList3"
    case storeList4 = "storeList4"
  }
  
  
  init() {
    self.storeList0 = []
    self.storeList1 = []
    self.storeList2 = []
    self.storeList3 = []
    self.storeList4 = []
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    storeList0 = try values.decodeIfPresent([StoreCard].self, forKey: .storeList0) ?? []
    storeList1 = try values.decodeIfPresent([StoreCard].self, forKey: .storeList1) ?? []
    storeList2 = try values.decodeIfPresent([StoreCard].self, forKey: .storeList2) ?? []
    storeList3 = try values.decodeIfPresent([StoreCard].self, forKey: .storeList3) ?? []
    storeList4 = try values.decodeIfPresent([StoreCard].self, forKey: .storeList4) ?? []
  }
  
  init(response: StoresGroupByReviewResponse) {
    self.storeList0 = response.storeList0.map(StoreCard.init)
    self.storeList1 = response.storeList1.map(StoreCard.init)
    self.storeList2 = response.storeList2.map(StoreCard.init)
    self.storeList3 = response.storeList3.map(StoreCard.init)
    self.storeList4 = response.storeList4.map(StoreCard.init)
  }
  
  func getStores() -> [StoreCard] {
    return self.storeList4 + self.storeList3 + self.storeList2 + self.storeList1 + self.storeList0
  }
}
