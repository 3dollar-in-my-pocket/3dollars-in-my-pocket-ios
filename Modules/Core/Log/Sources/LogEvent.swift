import Foundation

public struct LogEvent: LogEventType {
    public var screen: ScreenName
    public var name: EventName
    public var extraParameters: [ParameterName: Any]?
    
    public init(
        screen: ScreenName,
        eventName: EventName,
        extraParameters: [ParameterName : Any]? = nil
    ) {
        self.screen = screen
        self.name = eventName
        self.extraParameters = extraParameters
    }
}

public protocol LogEventType {
    var screen: ScreenName { set get }
    var name: EventName { set get }
    var extraParameters: [ParameterName: Any]? { set get }
}

public extension LogEventType {
    var parameters: [String: Any] {
        var result: [String: Any] = [:]
        
        if let extraParameters {
            extraParameters.forEach { key, value in
                if let objectId = value as? LogObjectId {
                    result[key.rawValue] = objectId.rawValue
                } else if let objectType = value as? LogObjectType {
                    result[key.rawValue] = objectType.rawValue
                } else {
                    result[key.rawValue] = value
                }
            }
        }
        
        result[ParameterName.screen.rawValue] = screen.rawValue
        return result
    }
}

public struct ClickEvent: LogEventType {
    public var screen: ScreenName
    public var name: EventName = .click
    public var extraParameters: [ParameterName : Any]?

    public init(
        screen: ScreenName,
        objectType: LogObjectType,
        objectId: LogObjectId,
        extraParameters: [ParameterName : Any]? = nil
    ) {
        self.screen = screen

        var clickObject: [ParameterName: Any] = [
            .objectId: objectId,
            .objectType: objectType
        ]

        if let extraParameters {
            clickObject.merge(extraParameters) { _, new in new }
        }

        self.extraParameters = clickObject
    }
}

public enum LogObjectType: String {
    case button
    case card
    case marker
    case banner
}

public enum LogObjectId: String {
    case signInApple = "sign_in_apple"
    case signInKakao = "sign_in_kakao"
    case signInAnonymous = "sign_in_anonymous"
    case signUp = "sign_up"
    case random
    case store
    case visit
    case currentLocation = "current_location"
    case address
    case categoryFilter = "category_filter"
    case bossFilter = "boss_filter"
    case sorting
    case recentActivityFilter = "recent_activity_filter"
    case onlyVisit = "only_visit"
    case doNotShowToday = "do_not_show_today"
    case close
    case bottomButton = "bottom_button"
    case favorite
    case report
    case share
    case navigation
    case writeReview = "write_review"
    case copyAddress = "copy_address"
    case zoomMap = "zoom_map"
    case like
    case sort
    case deleteReview = "delete_review"
    case visitSuccess = "visit_success"
    case visitFail = "visit_fail"
    case sns
    case copyAccount = "copy_account"
    case setAddress = "set_address"
    case category
    case banner
    case menu
    case advertisement
    case upload
    case boss
    case ok
    case install
}
