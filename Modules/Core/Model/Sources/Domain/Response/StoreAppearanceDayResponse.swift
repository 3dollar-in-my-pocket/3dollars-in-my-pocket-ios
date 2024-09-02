import Foundation

public struct StoreAppearanceDayResponse: Decodable {
    public let dayOfTheWeek: DayOfTheWeek
    public let openingHours: OpeningHours
    public let locationDescription: String

    public struct OpeningHours: Decodable {
        public let startTime: String
        public let endTime: String
    }
}
