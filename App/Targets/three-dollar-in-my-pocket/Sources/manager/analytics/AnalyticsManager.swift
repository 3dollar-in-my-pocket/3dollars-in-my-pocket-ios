import FirebaseAnalytics

protocol AnalyticsManagerProtocol {
    func logPageView(screen: AnalyticsScreen, type: AnyObject.Type)
    
    func logEvent(event: AnalyticsEvent, screen: AnalyticsScreen)
    
    func setPushEnable(isEnable: Bool)
    
    func setUser(id: String?)
}

final class AnalyticsManager: AnalyticsManagerProtocol {
    static let shared = AnalyticsManager()
    
    func logPageView(screen: AnalyticsScreen, type: AnyObject.Type) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screen.rawValue,
            AnalyticsParameterScreenClass: type.self
        ])
        debugPageViewEvent(screen: screen)
    }
    
    func logEvent(event: AnalyticsEvent, screen: AnalyticsScreen) {
        var parameters = event.parameters
        parameters["screen"] = screen.rawValue
        
        Analytics.logEvent(event.name, parameters: parameters)
        debugCustomEvent(event: event, parameters: parameters)
    }
    
    func setPushEnable(isEnable: Bool) {
        Analytics.setUserProperty("\(isEnable)", forName: "isPushEnable")
    }
    
    func setUser(id: String?) {
        Analytics.setUserID(id)
    }
    
    private func debugPageViewEvent(screen: AnalyticsScreen) {
        print("🧡 [AnalyticsManager]: PageView - \(screen.rawValue)")
    }
    
    private func debugCustomEvent(event: AnalyticsEvent, parameters: [String: Any]) {
        let message = """
        🧡 [AnalyticsManager]: CustomEvent
            => name: \(event.name)
            => parameter: \(event.parameters)
        """
        print(message)
    }
}

fileprivate extension Dictionary where Key == String {
    var prettyString: String {
        var result = ""
        for pair in self {
            result += "\n\t\(pair.key): \(pair.value),"
        }

        return result
    }
}
