import FirebaseAnalytics

typealias GA = GAManager

protocol GAManagerProtocol {
    func logEvent(event: GAEvent, page: GAPage)
}

class GAManager: GAManagerProtocol {
  
  static let shared = GAManager()
  
  func logEvent(event: GAEvent, page: GAPage) {
    Analytics.logEvent(event.rawValue, parameters: ["referral": page.rawValue])
  }
}
