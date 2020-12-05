import Foundation

struct UserDefaultsUtil {
  
  static let KEY_TOKEN = "KEY_TOKEN"
  static let KEY_USER_ID = "KEY_USER_ID"
  static let KEY_EVENT = "KEY_EVENT"
  
  let instance: UserDefaults
  
  
  init(name: String? = nil) {
    if let name = name {
      UserDefaults().removePersistentDomain(forName: name)
      instance = UserDefaults(suiteName: name)!
    } else {
      instance = UserDefaults.standard
    }
  }
  
  func setUserToken(token: String) {
    self.instance.set(token, forKey: UserDefaultsUtil.KEY_TOKEN)
  }
  
  func getUserToken() -> String {
    return self.instance.string(forKey: UserDefaultsUtil.KEY_TOKEN) ?? ""
  }
  
  func setUserId(id: Int) {
    self.instance.set(id, forKey: UserDefaultsUtil.KEY_USER_ID)
  }
  
  func getUserId() -> Int {
    return self.instance.integer(forKey: UserDefaultsUtil.KEY_USER_ID)
  }
  
  func setEventDisableToday(id: Int) {
    self.instance.set(DateUtils.todayString() ,forKey: "\(UserDefaultsUtil.KEY_EVENT)_\(id)")
  }
  
  func getEventDisableToday(id: Int) -> String {
    return self.instance.string(forKey: "\(UserDefaultsUtil.KEY_EVENT)_\(id)") ?? ""
  }
  
  func clear() {
    self.instance.removeObject(forKey: UserDefaultsUtil.KEY_USER_ID)
    self.instance.removeObject(forKey: UserDefaultsUtil.KEY_TOKEN)
  }
  
  static func setUserToken(token: String?) {
    UserDefaults.standard.set(token, forKey: UserDefaultsUtil.KEY_TOKEN)
  }
  
  static func getUserToken() -> String? {
    return UserDefaults.standard.string(forKey: UserDefaultsUtil.KEY_TOKEN)
  }
  
  static func setUserId(id: Int?) {
    UserDefaults.standard.set(id, forKey: UserDefaultsUtil.KEY_USER_ID)
  }
  
  static func getUserId() -> Int? {
    UserDefaults.standard.integer(forKey: UserDefaultsUtil.KEY_USER_ID)
  }
  
  static func setEventDisableToday(id: Int) {
    UserDefaults.standard.set(DateUtils.todayString() ,forKey: "\(UserDefaultsUtil.KEY_EVENT)_\(id)")
  }
  
  static func getEventDisableToday(id: Int) -> String? {
    return UserDefaults.standard.string(forKey: "\(UserDefaultsUtil.KEY_EVENT)_\(id)")
  }
  
  static func clear() {
    setUserId(id: nil)
    setUserToken(token: nil)
  }
}
