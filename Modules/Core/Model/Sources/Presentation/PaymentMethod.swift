import Foundation

public enum PaymentMethod: String, Hashable, Codable {
    case cash = "CASH"
    case accountTransfer = "ACCOUNT_TRANSFER"
    case card = "CARD"
    case unknown
    
    init(value: String) {
        self = PaymentMethod(rawValue: value) ??  .unknown
    }
    
    public init(from decoder: Decoder) throws {
        self = try PaymentMethod(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
