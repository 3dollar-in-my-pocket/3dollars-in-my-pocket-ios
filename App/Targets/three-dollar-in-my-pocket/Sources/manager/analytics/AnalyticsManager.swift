import FirebaseAnalytics

protocol AnalyticsManagerProtocol {
    func logEvent(event: AnalyticsEvent, screen: AnalyticsScreen)
    
    func setPushEnable(isEnable: Bool)
    
    func setUser(id: String?)
}

final class AnalyticsManager: AnalyticsManagerProtocol {
    static let shared = AnalyticsManager()
    
    func logEvent(event: AnalyticsEvent, screen: AnalyticsScreen) {
        var parameters = event.parameters
        parameters["screen"] = screen.rawValue
        
        Analytics.logEvent(event.name, parameters: parameters)
    }
    
    func setPushEnable(isEnable: Bool) {
        Analytics.setUserProperty("\(isEnable)", forName: "isPushEnable")
    }
    
    func setUser(id: String?) {
        Analytics.setUserID(id)
    }
}
