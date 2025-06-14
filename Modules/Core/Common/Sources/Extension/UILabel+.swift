import UIKit

import Model
import ZMarkupParser

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
    
    func setSDText(_ sdText: SDText) {
        textColor = UIColor(hex: sdText.fontColor)
        if sdText.isHtml {
            attributedText = ZHTMLParserBuilder.initWithDefault().build().render(sdText.text)
        } else {
            text = sdText.text
        }
    }
}
