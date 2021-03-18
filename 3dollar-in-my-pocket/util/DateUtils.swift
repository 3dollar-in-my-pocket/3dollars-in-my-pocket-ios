import Foundation

struct DateUtils {
  
  static func toDate(dateString: String) -> Date {
    let dateFormatter = DateFormatter().then {
      $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
      $0.locale = Locale(identifier: "ko")
    }
    
    return dateFormatter.date(from: dateString)!
  }
  
  static func todayString() -> String {
    let dateFormatter = DateFormatter().then {
      $0.dateFormat = "yyyy-MM-dd"
      $0.timeZone = NSTimeZone(name: "UTC") as TimeZone?
    }
    
    return dateFormatter.string(from: Date())
  }
  
  static func toReviewFormat(dateString: String) -> String {
    let date = toDate(dateString: dateString)
    let dateFormatter = DateFormatter().then {
      $0.dateFormat = "yy.MM.dd.E"
      $0.locale = Locale(identifier: "ko")
    }
    
    return dateFormatter.string(from: date)
  }
}
