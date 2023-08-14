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
}
