import Foundation

public extension Date {

    func toString(format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current

        return dateFormatter.string(from: self)
    }

    func addWeek(week: Int) -> Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: week, to: self) ?? Date()
    }

    func addMonth(month: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: month, to: self) ?? Date()
    }

    func addDay(day: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: day, to: self) ?? Date()
    }
    
    func toRelativeString() -> String {
        let currentDate = Date()
        let components = Calendar.current.dateComponents([.minute, .day], from: self, to: currentDate)

        if let minutesDifference = components.minute, minutesDifference < 1 {
            return "방금"
        }

        if let dayDifference = components.day, dayDifference > 1 {
            return self.toString()
        }

        let timeAgoFormatter = RelativeDateTimeFormatter()
        timeAgoFormatter.dateTimeStyle = .named
        timeAgoFormatter.unitsStyle = .short
        timeAgoFormatter.locale = Locale.current
        let dateToString = timeAgoFormatter.localizedString(for: self, relativeTo: currentDate)
        return dateToString
    }
}
