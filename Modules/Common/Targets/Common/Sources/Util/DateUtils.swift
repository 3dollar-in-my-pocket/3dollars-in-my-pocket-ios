import Foundation

public struct DateUtils {
    private static let defaultFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
    public static func toString(dateString: String, format: String? = nil) -> String {
        let date = Self.toDate(dateString: dateString)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format ?? Self.defaultFormat
        dateFormatter.locale = Locale(identifier: "ko")
        return dateFormatter.string(from: date)
    }
    
    public static func todayString(format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        return dateFormatter.string(from: Date())
    }

    public static func toString(date: Date, format: String?) -> String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = format ?? Self.defaultFormat
        dateFormatter.locale = Locale(identifier: "ko")
        return dateFormatter.string(from: date)
    }

    private static func toDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Self.defaultFormat
        dateFormatter.locale = Locale(identifier: "ko")
        
        return dateFormatter.date(from: dateString)!
    }
}
