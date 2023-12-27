public protocol AnalyticsManagerProtocol {
    func logPageView(screen: AnalyticsScreen, type: AnyObject.Type)
    
    func logEvent(event: AnalyticsEvent, screen: AnalyticsScreen)
    
    func setPushEnable(isEnable: Bool)
    
    func setUser(id: String?)
}
