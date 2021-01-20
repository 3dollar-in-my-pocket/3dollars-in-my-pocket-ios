enum StoreType: String {
  case road = "road"
  case store = "store"
  case convenienceStore = "convenienceStore"
  
  func getIndexValue() -> Int {
    switch self {
    case .road: return 0
    case .store: return 1
    case .convenienceStore: return 2
    }
  }
}
