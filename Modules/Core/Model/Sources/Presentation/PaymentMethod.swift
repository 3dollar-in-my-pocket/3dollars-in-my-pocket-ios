import Foundation

public enum PaymentMethod: String, Hashable {
    case cash = "CASH"
    case accountTransfer = "ACCOUNT_TRANSFER"
    case card = "CARD"
    case unknown
    
    init(value: String) {
        self = PaymentMethod(rawValue: value) ??  .unknown
    }
}
