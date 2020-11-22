import Foundation
import Alamofire
import UIKit

struct HTTPUtils {
  
  static let url = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String ?? ""
  
  static func jsonHeader() -> HTTPHeaders {
    return ["Accept": "application/json"]
  }
  
  static func defaultHeader() -> HTTPHeaders {
    return ["Authorization": UserDefaultsUtil().getUserToken()]
  }
  
  static func jsonWithTokenHeader() -> HTTPHeaders {
    return [
      "Accept": "application/json",
      "Authorization": UserDefaultsUtil().getUserToken()
    ]
  }
}
