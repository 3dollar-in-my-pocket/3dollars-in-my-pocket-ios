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
}
