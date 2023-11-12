import Foundation

public struct LogEvent {
    public let screen: ScreenName
    public let name: EventName
    public let extraParameters: [ParameterName: Any]?
    
    public init(
        screen: ScreenName,
        eventName: EventName,
        extraParameters: [ParameterName : Any]? = nil
    ) {
        self.screen = screen
        self.name = eventName
        self.extraParameters = extraParameters
    }
    
    public var parameters: [String: Any] {
        var result: [String: Any] = [:]
        
        if let extraParameters {
            extraParameters.forEach { key, value in
                result[key.rawValue] = value
            }
        }
        
        result[ParameterName.screen.rawValue] = screen.rawValue
        return result
    }
    
}
