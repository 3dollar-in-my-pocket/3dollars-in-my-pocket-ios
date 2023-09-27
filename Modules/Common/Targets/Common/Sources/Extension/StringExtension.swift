import Foundation

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

    func height(width: CGFloat) -> CGFloat {
        (self as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            context: nil
        ).size.height
    }
}
