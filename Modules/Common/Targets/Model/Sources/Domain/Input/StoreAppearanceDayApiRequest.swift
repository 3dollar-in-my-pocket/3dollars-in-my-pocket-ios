import Foundation

public struct StoreAppearanceDayApiRequest: Encodable {
    public let dayOfTheWeek: DayOfTheWeek
    public let startTime: String
    public let endTime: String
    public let extra: String?
    
    public init(
        dayOfTheWeek: DayOfTheWeek,
        startTime: String,
        endTime: String,
        extra: String? = nil
    ) {
        self.dayOfTheWeek = dayOfTheWeek
        self.startTime = startTime
        self.endTime = endTime
        self.extra = extra
    }
}
