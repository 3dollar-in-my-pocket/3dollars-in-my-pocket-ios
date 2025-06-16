import Foundation

public enum SalesType: String, Hashable, Codable {
    case road = "ROAD"
    case store = "STORE"
    case convenienceStore = "CONVENIENCE_STORE"
    case unknown
    
    public init?(value: String?) {
        if let value {
            self = SalesType(rawValue: value) ??  .unknown
        } else {
            return nil
        }
    }
    
    public init(from decoder: Decoder) throws {
        let rawValue = try? decoder.singleValueContainer().decode(RawValue.self)
        self = SalesType(value: rawValue) ?? .unknown
    }
    
    public func getIndexValue() -> Int {
        switch self {
        case .road: return 0
        case .store: return 1
        case .convenienceStore: return 2
        case .unknown: return 3
        }
    }
}
