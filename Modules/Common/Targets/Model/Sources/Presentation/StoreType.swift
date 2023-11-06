import Foundation

public enum StoreType: String {
    case userStore = "USER_STORE"
    case bossStore = "BOSS_STORE"
    
    public init(value: String) {
        self = StoreType(rawValue: value) ?? .userStore
    }
}

public extension StoreType {
    var kakaoParameterValue: String {
        switch self {
        case .bossStore:
            return "foodTruck"
            
        case .userStore:
            return "streetFood"
        }
    }
}
