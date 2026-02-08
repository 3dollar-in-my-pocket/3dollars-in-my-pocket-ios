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
    
    func setSDText(_ sdText: SDText, customFont: UIFont? = nil) {
        textColor = UIColor(hex: sdText.fontColor)
        if sdText.isHtml {
            var parser = ZHTMLParserBuilder.initWithDefault()
            
            if let customFont {
                let rootStyle = MarkupStyle(font: MarkupStyleFont(customFont))
                parser = parser.set(rootStyle: rootStyle)
            }
            
            let boldStyle = MarkupStyle(
                font: MarkupStyleFont(
                    weight: .style(.bold),
                    bold: true
                )
            )
            parser = parser.set(B_HTMLTagName(), withCustomStyle: boldStyle)
            
            attributedText = parser.build().render(sdText.text)
        } else {
            text = sdText.text
            if let font = customFont {
                self.font = font
            }
        }
    }
}
