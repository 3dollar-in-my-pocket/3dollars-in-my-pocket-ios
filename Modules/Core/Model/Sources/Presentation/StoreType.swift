import Foundation

public enum StoreType: String, Encodable {
    case userStore = "USER_STORE"
    case bossStore = "BOSS_STORE"
    case unknown
    
    public init(value: String) {
        self = StoreType(rawValue: value) ?? .userStore
    }
}

extension StoreType: Decodable {
    public init(from decoder: Decoder) throws {
        self = try StoreType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public extension StoreType {
    var kakaoParameterValue: String {
        switch self {
        case .bossStore:
            return "foodTruck"
        case .userStore:
            return "streetFood"
        case .unknown:
            return "unknown"
        }
    }
}
