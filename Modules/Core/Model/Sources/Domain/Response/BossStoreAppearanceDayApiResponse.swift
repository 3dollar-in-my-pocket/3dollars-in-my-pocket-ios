import Foundation

public struct BossStoreAppearanceDayApiResponse: Decodable {
    public let dayOfTheWeek: DayOfTheWeek
    public let openingHours: TimeInterval
    public let locationDescription: String

    public struct TimeInterval: Decodable {
        public let startTime: String
        public let endTime: String
    }
}
