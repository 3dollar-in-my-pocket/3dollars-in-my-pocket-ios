enum PaymentType: String, Codable {
  case cash = "CASH"
  case card = "CARD"
  case transfer = "ACCOUNT_TRANSFER"
  
  func getIndexValue() -> Int {
    switch self {
    case .cash: return 0
    case .card: return 1
    case .transfer: return 2
    }
  }
}
