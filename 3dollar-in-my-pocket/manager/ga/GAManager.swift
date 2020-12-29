import FirebaseAnalytics

typealias GA = GAManager

class GAManager {
  
  static let shared = GAManager()
  
  func logEvent(event: GAEvent, page: GAPage) {
    Analytics.logEvent(event.rawValue, parameters: ["referral" : page.rawValue])
  }
}
