import Foundation

enum StoreType: String {
    case userStore = "USER_STORE"
    case bossStore = "BOSS_STORE"
    
    init(value: String) {
        self = StoreType(rawValue: value) ?? .userStore
    }
}
