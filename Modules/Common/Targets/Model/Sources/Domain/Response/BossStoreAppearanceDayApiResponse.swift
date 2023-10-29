import Foundation

public struct BossStoreAppearanceDayApiResponse: Decodable {
    public let dayOfTheWeek: DayOfTheWeek
    public let openingHours: TimeInterval
    public let locationDescription: String

    public enum DayOfTheWeek: String, Decodable {
        case monday = "MONDAY"
        case tuesday = "TUESDAY"
        case wednesday = "WEDNESDAY"
        case thursday = "THURSDAY"
        case friday = "FRIDAY"
        case satureday = "SATURDAY"
        case sunday = "SUNDAY"
    }

    public struct TimeInterval: Decodable {
        public let startTime: String
        public let endTime: String
    }
}
