import Foundation

public enum StoreType: String {
    case userStore = "USER_STORE"
    case bossStore = "BOSS_STORE"
    
    public init(value: String) {
        self = StoreType(rawValue: value) ?? .userStore
    }
}
