import Foundation

public struct BossStoreAppearanceDay: Hashable {
    public let dayOfTheWeek: DayOfTheWeek
    public let locationDescription: String
    public let openingHours: Date
    public let closingHours: Date
    public let isClosedDay: Bool

    public init(response: StoreAppearanceDayResponse) {
        self.dayOfTheWeek = response.dayOfTheWeek
        self.locationDescription = response.locationDescription

        self.openingHours = Self.toDate(
            dateString: response.openingHours.startTime,
            format: "HH:mm"
        )
        self.closingHours = Self.toDate(
            dateString: response.openingHours.endTime,
            format: "HH:mm"
        )
        self.isClosedDay = false
    }

    public init(dayOfTheWeek: DayOfTheWeek) {
        self.dayOfTheWeek = dayOfTheWeek
        self.locationDescription = "-"
        self.openingHours = Date()
        self.closingHours = Date()
        self.isClosedDay = true
    }
}

public extension BossStoreAppearanceDay {
    var index: Int {
        switch self.dayOfTheWeek {
        case .monday:
            return 0

        case .tuesday:
            return 1

        case .wednesday:
            return 2

        case .thursday:
            return 3

        case .friday:
            return 4

        case .saturday:
            return 5

        case .sunday:
            return 6
        }
    }

    private static func toDate(dateString: String, format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "ko")

        return dateFormatter.date(from: dateString)!
    }
}
