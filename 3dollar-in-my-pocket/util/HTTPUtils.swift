import Foundation
import Alamofire
import UIKit

struct HTTPUtils {
  
  static let url = Bundle.main.object(forInfoDictionaryKey: "API_URL") as? String ?? ""
  
  static let defaultSession: Session = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 4
    
    return Session(configuration: configuration)
  }()
  
  static let fileUploadSession: Session = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30
    
    return Session(configuration: configuration)
  }()
  
  static func jsonHeader() -> HTTPHeaders {
    var headers = ["Accept": "application/json"] as HTTPHeaders
    
    headers.add(self.defaultUserAgent)
    return headers
  }
  
  static func defaultHeader() -> HTTPHeaders {
    var headers = ["Authorization": UserDefaultsUtil().getUserToken()] as HTTPHeaders
    
    headers.add(self.defaultUserAgent)
    return headers
  }
  
  static func jsonWithTokenHeader() -> HTTPHeaders {
    var headers = [
      "Accept": "application/json",
      "Authorization": UserDefaultsUtil().getUserToken()
    ] as HTTPHeaders
    
    headers.add(self.defaultUserAgent)
    return headers
  }
  
  // Timeout header 테스트용으로 추가하는 함수
  static func addTimeoutHeader(headers: HTTPHeaders) -> HTTPHeaders {
    let timeOutHeader = HTTPHeader(name: "X-3DOLLAR-SLEEP-MILLISECONDS", value: "4000")
    var newHeaders = headers
    
    newHeaders.add(timeOutHeader)
    return newHeaders
  }
  
  static let defaultUserAgent: HTTPHeader = {
      let info = Bundle.main.infoDictionary
      let executable = (info?[kCFBundleExecutableKey as String] as? String) ??
          (ProcessInfo.processInfo.arguments.first?.split(separator: "/").last.map(String.init)) ??
          "Unknown"
      let bundle = info?[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
      let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
      let appBuild = info?[kCFBundleVersionKey as String] as? String ?? "Unknown"

      let osNameVersion: String = {
          let version = ProcessInfo.processInfo.operatingSystemVersion
          let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
          let osName: String = "iOS"

          return "\(osName) \(versionString)"
      }()

      let userAgent = "\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"

      return .userAgent(userAgent)
  }()
}
