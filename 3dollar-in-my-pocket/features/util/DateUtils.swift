import Foundation

struct DateUtils {
    static func todayString() -> String {
        let dateFormatter = DateFormatter().then {
            $0.dateFormat = "yyyy-MM-dd"
            $0.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        }
        
        return dateFormatter.string(from: Date())
    }
}
