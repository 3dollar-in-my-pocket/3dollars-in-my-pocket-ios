import Foundation
import UIKit

public extension String {
    func maxLength(length: Int) -> String {
        var string = self
        let nsString = string as NSString
        if nsString.length >= length {
            let substringRange = NSRange(
                location: 0,
                length: nsString.length > length ? length : nsString.length
            )
            string = nsString.substring(with: substringRange)
        }
        return  string
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    /**
     - 1분 미만인 경우 -> 방금 전
     - 60분 미만인 경우 -> n분 전
     - 24시간 미만인 경우 -> n시간 전
     - 48시간 미만인 경우 -> n일 전
     - 나머지 -> yyyy년MM월dd일 포맷
     */
    var createdAtFormatted: String {
        let date = DateUtils.toDate(dateString: self)
        let timeDiff = abs(date.timeIntervalSinceNow)
        let second = Int(timeDiff)
        
        let minuteInSeconds = 60
        let hourInSeconds = 60 * minuteInSeconds
        let dayInSeconds = hourInSeconds * 24
        let twoDayInSeconds = dayInSeconds * 2
        
        
        switch second {
        case 0...minuteInSeconds:
            return "방금 전"
        case minuteInSeconds...hourInSeconds:
            let minutes = second / 60
            return "\(minutes)분 전"
        case hourInSeconds...dayInSeconds:
            let hour = second / hourInSeconds
            return "\(hour)시간 전"
        case dayInSeconds...twoDayInSeconds:
            let days = second / dayInSeconds
            return "\(days)일 전"
        default:
            let formattedDate = DateUtils.toString(date: date, format: "yyyy년MM월dd일")
            
            return formattedDate
            
        }
    }

    func toDate(format: String? = "yyyy-MM-dd'T'HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }

    func height(font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.size.height)
    }
    
    func width(font: UIFont, height: CGFloat) -> CGFloat {
        return NSAttributedString(string: self, attributes: [NSAttributedString.Key.font: font])
            .width(height: height)
    }
    
    func height(font: UIFont?, width: CGFloat) -> CGFloat {
        guard let font = font else { return .zero }
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let height = (self as NSString).boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font as Any],
            context: nil
        ).height
        
        return height
    }
    
    var decimal: Int {
        let trimmed = replacingOccurrences(of: ",", with: "")
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = formatter.number(from: trimmed)
        return number?.intValue ?? 0
    }
}
