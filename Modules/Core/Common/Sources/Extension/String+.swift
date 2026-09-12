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
    
    var numberOfLines: Int {
        return self.components(separatedBy: "\n").count
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

    func height(font: UIFont, width: CGFloat, lineHeight: CGFloat? = nil) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        var attributes: [NSAttributedString.Key: Any] = [.font: font]
        if let lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            attributes[.paragraphStyle] = paragraphStyle
        }
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)

        return ceil(boundingBox.size.height)
    }

    func width(font: UIFont, height: CGFloat) -> CGFloat {
        return NSAttributedString(string: self, attributes: [NSAttributedString.Key.font: font])
            .width(height: height)
    }

    func height(font: UIFont?, width: CGFloat, lineHeight: CGFloat? = nil) -> CGFloat {
        guard let font = font else { return .zero }
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        var attributes: [NSAttributedString.Key: Any] = [.font: font as Any]
        if let lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            attributes[.paragraphStyle] = paragraphStyle
        }
        let height = (self as NSString).boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        ).height

        return height
    }
    
    /// 서버가 HTML(SDText.isHtml)로 내려준 문자열에서 태그를 걷어내고 순수 텍스트만 남긴다.
    /// 라벨 렌더링은 파서를 쓰지만, 네비게이션 타이틀·공유 문구처럼 문자열 자체가 필요한 곳에 쓴다.
    var htmlStripped: String {
        let withoutTags = replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)

        // `&amp;` 를 마지막에 치환해야 `&amp;lt;` 같은 이중 이스케이프가 깨지지 않는다.
        return withoutTags
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var decimal: Int? {
        let trimmed = replacingOccurrences(of: ",", with: "")
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = formatter.number(from: trimmed)
        return number?.intValue
    }
}
