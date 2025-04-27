import Foundation

public extension NSAttributedString {
    func size(_ size: CGSize) -> CGSize {
        boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).size
    }
    
    func height(width: CGFloat) -> CGFloat {
        size(CGSize(width: width, height: .greatestFiniteMagnitude)).height
    }
    
    func width(height: CGFloat) -> CGFloat {
        size(CGSize(width: .greatestFiniteMagnitude, height: height)).width
    }
}
