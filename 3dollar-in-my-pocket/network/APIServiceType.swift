import Foundation

protocol APIServiceType {
}

extension APIServiceType {
  static func url(_ path: String) -> String {
    guard let url = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String else { return "" }
    
    return "\(url)/\(path)"
  }
  
  static func jsonHeader() -> [String: String] {
    return ["Accept": "application/json"]
  }
  
  static func defaultHeader() -> [String: String] {
    return ["Authorization": UserDefaultsUtil.getUserToken()!]
  }
  
  static func jsonWithTokenHeader() -> [String: String] {
    return ["Accept": "application/json",
            "Authorization": UserDefaultsUtil.getUserToken()!]
  }
}
