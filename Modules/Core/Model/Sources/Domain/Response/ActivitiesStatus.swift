import Foundation

public enum ActivitiesStatus: String, Codable {
    case recentActivity = "RECENT_ACTIVITY"
    case noRecentActivity = "NO_RECENT_ACTIVITY"
    case unknown

    public init(from decoder: Decoder) throws {
        self = try ActivitiesStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
