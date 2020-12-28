import FirebaseAnalytics

typealias GA = GAManager

class GAManager {
  
  static let shared = GAManager()
  
  func logEvent(event: GAEvent, className: AnyClass) {
    Analytics.logEvent(event.rawValue, parameters: ["referral" : "\(className.self)"])
  }
}
