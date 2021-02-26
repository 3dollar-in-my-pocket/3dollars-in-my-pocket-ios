struct CategoryByDistance: Codable {
  
  let storeList50: [StoreCard]
  let storeList100: [StoreCard]
  let storeList500: [StoreCard]
  let storeList1000: [StoreCard]
  let storeListOver1000: [StoreCard]
  var indexList: [Int] = []
  
  enum CodingKeys: String, CodingKey {
    case storeList50 = "storeList50"
    case storeList100 = "storeList100"
    case storeList500 = "storeList500"
    case storeList1000 = "storeList1000"
    case storeListOver1000 = "storeListOver1000"
  }
  
  
  init() {
    self.storeList50 = []
    self.storeList100 = []
    self.storeList500 = []
    self.storeList1000 = []
    self.storeListOver1000 = []
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    
    storeList50 = try values.decodeIfPresent([StoreCard].self, forKey: .storeList50) ?? []
    storeList100 = try values.decodeIfPresent([StoreCard].self, forKey: .storeList100) ?? []
    storeList500 = try values.decodeIfPresent([StoreCard].self, forKey: .storeList500) ?? []
    storeList1000 = try values.decodeIfPresent([StoreCard].self, forKey: .storeList1000) ?? []
    storeListOver1000 = try values.decodeIfPresent([StoreCard].self, forKey: .storeListOver1000) ?? []
  }
  
  func getStores() -> [StoreCard] {
    return self.storeList50 + self.storeList100 + self.storeList500 + self.storeList1000 + self.storeListOver1000
  }
}
