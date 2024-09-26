import Foundation

public enum AppearanceDay: String, Hashable, Codable {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
    case unknown
    
    init(value: String) {
        self = AppearanceDay(rawValue: value) ??  .unknown
    }
    
    public init(from decoder: Decoder) throws {
        self = try AppearanceDay(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
