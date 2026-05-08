import Foundation

public enum FilterOpenStatuses: String, Codable {
    case open = "OPEN"
    case closed = "CLOSED"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try FilterOpenStatuses(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
