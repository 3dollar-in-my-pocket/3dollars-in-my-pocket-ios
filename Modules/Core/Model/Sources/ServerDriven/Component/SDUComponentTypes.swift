import Foundation

public enum SDUComponentTypes: String, Decodable {
    case calloutCard = "CALLOUT_CARD"
    case iconTextCard = "ICON_TEXT_CARD"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try SDUComponentTypes(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

public protocol SDUComponent: Decodable {
    var type: SDUComponentTypes { get }
}
