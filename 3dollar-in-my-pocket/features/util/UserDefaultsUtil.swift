import Foundation

struct UserDefaultsUtil {
    
    static let KEY_TOKEN = "KEY_TOKEN"
    
    static func setUserToken(token: String) {
        UserDefaults.standard.set(token, forKey: UserDefaultsUtil.KEY_TOKEN)
    }
    
    static func getUserToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsUtil.KEY_TOKEN)
    }
}
