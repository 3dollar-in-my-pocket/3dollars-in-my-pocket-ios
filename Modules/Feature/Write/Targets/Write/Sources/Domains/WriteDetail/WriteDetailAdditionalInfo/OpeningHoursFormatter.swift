import Foundation

import Common

enum OpeningHoursFormatter {
    static func string(from date: Date) -> String {
        let minute = Calendar.current.component(.minute, from: date)
        let format = minute == 0
            ? Strings.WriteAdditionalInfo.OpeningHours.dateFormat
            : Strings.WriteAdditionalInfo.OpeningHours.dateFormatWithMinute
        return date.toString(format: format)
    }
}
