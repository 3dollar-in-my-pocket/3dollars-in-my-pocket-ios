import Foundation

struct UserDefaultsUtil {
    
    static let KEY_TOKEN = "KEY_TOKEN"
    static let KEY_USER_ID = "KEY_USER_ID"
    
    static func setUserToken(token: String) {
        UserDefaults.standard.set(token, forKey: UserDefaultsUtil.KEY_TOKEN)
    }
    
    static func getUserToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsUtil.KEY_TOKEN)
    }
    
    static func setUserId(id: Int) {
        UserDefaults.standard.set(id, forKey: UserDefaultsUtil.KEY_USER_ID)
    }
    
    static func getUserId() -> Int? {
        UserDefaults.standard.integer(forKey: UserDefaultsUtil.KEY_USER_ID)
    }
}
