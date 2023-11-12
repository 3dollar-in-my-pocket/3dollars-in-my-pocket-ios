import Foundation
import OSLog

public protocol LogManagerProtocol {
    func sendPageView(screen: ScreenName, type: AnyObject.Type)
    
    func sendEvent(_ event: LogEvent)
}

public final class LogManager: LogManagerProtocol {
    public static let shared = LogManager()
    private var isEnableDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    public func sendPageView(screen: ScreenName, type: AnyObject.Type) {
        Environment.appModuleInterface.sendPageView(screenName: screen.rawValue, type: type)
        
        if isEnableDebug {
            debugPageView(screen: screen, type: type)
        }
    }
    
    public func sendEvent(_ event: LogEvent) {
        Environment.appModuleInterface.sendEvent(
            name: event.name.rawValue,
            parameters: event.parameters
        )
        
        if isEnableDebug {
            debugCustomEvent(event)
        }
    }
    
    private func debugPageView(screen: ScreenName, type: AnyObject.Type) {
        let message: StaticString = """
        🧡 [LogManager]: PageView
            => screen: %{PUBLIC}@
            => type: %{PUBLIC}@
        """
        
        os_log(.debug, message, screen.rawValue, String(describing: type))
    }
    
    private func debugCustomEvent(_ event: LogEvent) {
        let message: StaticString = """
        🧡 [LogManager]: CustomEvent
            => name: %{PUBLIC}@
            => parameter: %{PUBLIC}@
        """
        
        os_log(.debug, message, event.name.rawValue, event.parameters.prettyString)
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
