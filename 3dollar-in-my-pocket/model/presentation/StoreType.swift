enum StoreType: String, Codable {
  case road = "ROAD"
  case store = "STORE"
  case convenienceStore = "CONVENIENCE_STORE"
  
  func getIndexValue() -> Int {
    switch self {
    case .road: return 0
    case .store: return 1
    case .convenienceStore: return 2
    }
  }
  
  func getString() -> String {
    switch self {
    case .road: return "shared_store_type_road".localized
    case .store: return "shared_store_type_store".localized
    case .convenienceStore: return "shared_store_type_convenience_store".localized
    }
  }
}
