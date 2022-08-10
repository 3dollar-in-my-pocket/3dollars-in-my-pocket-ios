import FirebaseAnalytics

typealias GA = GAManager

protocol GAManagerProtocol {
    func logEvent(event: GAEvent, page: GAPage)
}

final class GAManager: GAManagerProtocol {
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
}
