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

    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.date(from: self)
    }

    func height(font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.size.height)
    }
}
