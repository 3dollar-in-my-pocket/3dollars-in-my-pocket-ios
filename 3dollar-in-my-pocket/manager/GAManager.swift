import FirebaseAnalytics

typealias GA = GAManager

class GAManager {
  
  static let shared = GAManager()
  
  func logEvent(event: GAEvent) {
    Analytics.logEvent(event.rawValue, parameters: nil)
  }
}
