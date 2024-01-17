import UIKit

public extension UILabel {
    func setKern(kern: Float) {
        guard let text = text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttribute(
            .kern,
            value: kern,
            range: .init(location: 0, length: text.count)
        )
        attributedText = attributedString
    }
    
    func setLineHeight(lineHeight: CGFloat) {
        guard let text = text else { return }
        let style = NSMutableParagraphStyle()
        
        style.maximumLineHeight = lineHeight
        style.minimumLineHeight = lineHeight
        
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [.paragraphStyle: style]
        )
        
        attributedText = attributedString
    }
}
