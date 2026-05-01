import Foundation

import Model

public protocol LogEventType {
    var screen: ScreenName { set get }
    var name: EventName { set get }
    var extraParameters: [ParameterName: Any]? { set get }
    /// GA 로 전송될 최종 파라미터. 기본 구현은 extension 에 있으며, 서버 드리븐(SDClickEvent) 등은 자체 구현으로 오버라이드한다.
    var parameters: [String: Any] { get }
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

    /// 서버 응답으로 내려오는 동적 식별자(logKey 등)를 object_id 로 보낼 때 사용.
    public init(
        screen: ScreenName,
        objectType: LogObjectType,
        objectId: String,
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

public struct ImpressionEvent: LogEventType {
    public var screen: ScreenName
    public var name: EventName = .impression
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

/// 서버 드리븐 SDClickLog 를 GA 로그로 직렬화하는 ClickEvent 변형.
/// - SDClickLog.screenName 은 GA `screen` 으로
/// - SDClickLog.objectType / objectId 는 `extraParameters` 의 object_type / object_id 로
/// - SDClickLog.extraParameters 는 그대로 GA 파라미터에 병합.
public struct SDClickEvent: LogEventType {
    public var screen: ScreenName = .empty
    public var name: EventName = .click
    public var extraParameters: [ParameterName: Any]?

    private let clickLog: SDClickLog

    public init(clickLog: SDClickLog, additionalParameters: [ParameterName: Any]? = nil) {
        self.clickLog = clickLog
        self.extraParameters = additionalParameters
    }

    public var parameters: [String: Any] {
        var result: [String: Any] = [:]
        result[ParameterName.screen.rawValue] = clickLog.screenName
        result[ParameterName.objectType.rawValue] = clickLog.objectType
        result[ParameterName.objectId.rawValue] = clickLog.objectId

        for (key, value) in clickLog.extraParameters {
            if let raw = value.anyValue {
                result[key] = raw
            }
        }

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
        return result
    }
}

public struct CustomEvent: LogEventType {
    public var screen: ScreenName
    public var name: EventName
    public var extraParameters: [ParameterName : Any]?
    
    public init(
        screen: ScreenName,
        name: EventName,
        extraParameters: [ParameterName : Any]? = nil
    ) {
        self.screen = screen
        self.name = name
        self.extraParameters = extraParameters
    }
}

public enum LogObjectType: String {
    case button
    case card
    case marker
    case banner
    case tab
    case medal
    case review
    case menu
    case carousel
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
    case next
    case skip
    case category
    case banner
    case menu
    case photo
    case advertisement
    case upload
    case boss
    case ok
    case install
    case addMenu = "add_menu"
    case addAdditionalInfo = "add_additional_info"
    case location
    case info
    case edit
    case feed
    case poll
    case pollOption = "poll_option"
    case pollCategory = "poll_category"
    case district
    case filter
    case createPoll = "create_poll"
    case reportReview = "report_review"
    case create
    case medal
    case visitedStore = "visited_store"
    case favoritedStore = "favorited_store"
    case review
    case recommendStore
    case recommend
}
