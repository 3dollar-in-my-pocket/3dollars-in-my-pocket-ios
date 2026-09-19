import Foundation

import Log

/// LogManagerProtocol 스파이. 전송된 로그를 기록만 하고 실제로 보내지 않는다.
final class MockLogManager: LogManagerProtocol {
    private(set) var pageViews: [(screen: ScreenName, parameters: [ParameterName: Any]?)] = []
    private(set) var sentEvents: [any LogEventType] = []

    func sendPageView(screen: ScreenName, type: AnyObject.Type) {
        pageViews.append((screen, nil))
    }

    func sendPageView(screen: ScreenName, type: AnyObject.Type, extraParameters: [ParameterName: Any]?) {
        pageViews.append((screen, extraParameters))
    }

    func sendEvent(event: any LogEventType) {
        sentEvents.append(event)
    }
}
