enum PaymentType: String {
  case cash = "caes"
  case card = "card"
  case transfer = "transfer"
  
  func getIndexValue() -> Int {
    switch self {
    case .cash: return 0
    case .card: return 1
    case .transfer: return 2
    }
  }
}
