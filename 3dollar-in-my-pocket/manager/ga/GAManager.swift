import FirebaseAnalytics

typealias GA = GAManager

protocol AnalyticsManagerProtocol {
    func logEvent(event: GAEvent, page: GAPage)
    
    func setPushEnable(isEnable: Bool)
    
    func setUser(id: String?)
}

final class GAManager: AnalyticsManagerProtocol {
    static let shared = GAManager()
    
    func logEvent(event: GAEvent, page: GAPage) {
        switch event {
        case .view_boss_store_detail(let storeId):
            Analytics.logEvent(
                event.name,
                parameters: [
                    "referral": page.rawValue,
                    "storeId": storeId
                ]
            )
            
        default:
            Analytics.logEvent(event.name, parameters: ["referral": page.rawValue])
        }
    }
    
    func setPushEnable(isEnable: Bool) {
        Analytics.setUserProperty("\(isEnable)", forName: "isPushEnable")
    }
    
    func setUser(id: String?) {
        Analytics.setUserID(id)
    }
}
