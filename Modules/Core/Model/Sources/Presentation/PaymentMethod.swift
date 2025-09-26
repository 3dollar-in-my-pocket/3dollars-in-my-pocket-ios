import Foundation

public enum PaymentMethod: String, Hashable, Codable, Comparable {
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

    public static func < (lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
    
    private var sortOrder: Int {
        switch self {
        case .cash: return 0
        case .accountTransfer: return 1
        case .card: return 2
        case .unknown: return 999
        }
    }
}
