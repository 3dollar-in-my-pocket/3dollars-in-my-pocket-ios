import Foundation

struct DateUtils {
    private static let defaultFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
    @available(*, deprecated, message: "사라질 예정")
    static func toDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            $0.locale = Locale(identifier: "ko")
        }
        
        return dateFormatter.date(from: dateString)!
    }
    
    @available(*, deprecated, message: "사라질 예정")
    static func todayString() -> String {
        let dateFormatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd"
            $0.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        }
        
        return dateFormatter.string(from: Date())
    }
    
    @available(*, deprecated, message: "사라질 예정")
    static func toReviewFormat(dateString: String) -> String {
        let date = toDate(dateString: dateString)
        let dateFormatter = DateFormatter().then {
            $0.dateFormat = "yy.MM.dd.E"
            $0.locale = Locale(identifier: "ko")
        }
        
        return dateFormatter.string(from: date)
    }
    
    @available(*, deprecated, message: "사라질 예정")
    static func toUpdatedAtFormat(dateString: String) -> String {
        let date = toDate(dateString: dateString)
        let dateFormatter = DateFormatter().then {
            $0.dateFormat = "yy.MM.dd 업데이트"
            $0.locale = Locale(identifier: "ko")
        }
        
        return dateFormatter.string(from: date)
    }
    
    @available(*, deprecated, message: "사라질 예정")
    static func toString(dateString: String, format: String) -> String {
        let date = toDate(dateString: dateString)
        let dateFormatter = DateFormatter().then {
            $0.dateFormat = format
            $0.locale = Locale(identifier: "ko")
        }
        
        return dateFormatter.string(from: date)
    }
    
    static func toString(dateString: String, format: String?) -> String {
        let date = Self.toDate(dateString: dateString)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format ?? Self.defaultFormat
        dateFormatter.locale = Locale(identifier: "ko")
        return dateFormatter.string(from: date)
    }
    
    static func toString(date: Date, format: String?) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format ?? Self.defaultFormat
        dateFormatter.locale = Locale(identifier: "ko")
        return dateFormatter.string(from: date)
    }
    
    static func todayString(format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        return dateFormatter.string(from: Date())
    }
    
    static func toDate(dateString: String, format: String? = nil) -> Date {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format ?? Self.defaultFormat
        dateFormatter.locale = Locale(identifier: "ko")
        
        return dateFormatter.date(from: dateString)!
    }
}
