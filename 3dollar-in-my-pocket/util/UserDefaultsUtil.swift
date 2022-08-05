import Foundation
import CoreLocation

struct UserDefaultsUtil {
  
  static let KEY_TOKEN = "KEY_TOKEN"
  static let KEY_USER_ID = "KEY_USER_ID"
  static let KEY_EVENT = "KEY_EVENT"
  static let KEY_DETAIL_LINK = "KEY_DETAIL_LINK"
  static let KEY_CURRENT_LATITUDE = "KEY_CURRENT_LATITUDE"
  static let KEY_CURRENT_LONGITUDE = "KEY_CURRENT_LONGITUDE"
    static let KEY_FOODTRUCK_TOOLTIP = "KEY_FOODTRUCK_TOOLTIP"
  
  let instance: UserDefaults
  
  
  init(name: String? = nil) {
    if let name = name {
      UserDefaults().removePersistentDomain(forName: name)
      instance = UserDefaults(suiteName: name)!
    } else {
      instance = UserDefaults.standard
    }
  }
    
    var isFoodTruckTooltipShown: Bool {
        get {
            self.instance.bool(forKey: UserDefaultsUtil.KEY_FOODTRUCK_TOOLTIP)
        }
        set {
            self.instance.set(newValue, forKey: UserDefaultsUtil.KEY_FOODTRUCK_TOOLTIP)
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
  
  func setDetailLink(storeId: Int) {
    self.instance.set(storeId, forKey: UserDefaultsUtil.KEY_DETAIL_LINK)
  }
  
  func getDetailLink() -> Int {
    return self.instance.integer(forKey: UserDefaultsUtil.KEY_DETAIL_LINK)
  }
  
  func setUserCurrentLocation(location: CLLocation) {
    self.instance.set(
      location.coordinate.latitude,
      forKey: UserDefaultsUtil.KEY_CURRENT_LATITUDE
    )
    self.instance.set(
      location.coordinate.longitude,
      forKey: UserDefaultsUtil.KEY_CURRENT_LONGITUDE
    )
  }
  
  func getUserCurrentLocation() -> CLLocation {
    let latitude = self.instance.double(forKey: UserDefaultsUtil.KEY_CURRENT_LATITUDE)
    let longitude = self.instance.double(forKey: UserDefaultsUtil.KEY_CURRENT_LONGITUDE)
    
    return CLLocation(latitude: latitude, longitude: longitude)
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
