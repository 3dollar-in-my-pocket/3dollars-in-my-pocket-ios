import Foundation

public struct LogEvent {
    public let screen: ScreenName
    public let eventType: EventType
    public let objectType: ObjectType
    public let objectId: String
    public let extraParameters: [ParameterName: Any]?
    
    public init(
        screen: ScreenName,
        eventType: EventType,
        objectType: ObjectType,
        objectId: String,
        extraParameters: [ParameterName : Any]? = nil
    ) {
        self.screen = screen
        self.eventType = eventType
        self.objectType = objectType
        self.objectId = objectId
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
        result[ParameterName.objectId.rawValue] = objectId
        result[ParameterName.objectType.rawValue] = objectType.rawValue
        return result
    }
    
}

public enum EventType: String {
    case click
}

public enum ObjectType: String {
    case button
    case card
    case marker
    case inputField = "input_field"
}

