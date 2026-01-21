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
        let style: NSMutableParagraphStyle

        if let existingAttributedText = attributedText {
            let mutableAttributedString = NSMutableAttributedString(attributedString: existingAttributedText)
            let fullRange = NSRange(location: 0, length: mutableAttributedString.length)

            if let existingStyle = mutableAttributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                style = existingStyle.mutableCopy() as! NSMutableParagraphStyle
            } else {
                style = NSMutableParagraphStyle()
            }

            style.maximumLineHeight = lineHeight
            style.minimumLineHeight = lineHeight
            style.alignment = textAlignment

            mutableAttributedString.addAttribute(
                .paragraphStyle,
                value: style,
                range: fullRange
            )
            attributedText = mutableAttributedString
        } else if let text = text {
            style = NSMutableParagraphStyle()
            style.maximumLineHeight = lineHeight
            style.minimumLineHeight = lineHeight
            style.alignment = textAlignment

            let attributedString = NSMutableAttributedString(
                string: text,
                attributes: [.paragraphStyle: style]
            )
            attributedText = attributedString
        } else {
            return
        }
    }
    
    func setSDText(_ sdText: SDText) {
        textColor = UIColor(hex: sdText.fontColor)
        if sdText.isHtml {
            attributedText = ZHTMLParserBuilder.initWithDefault().build().render(sdText.text)
        } else {
            text = sdText.text
        }
    }
    
    func setSDChip(_ sdChip: SDChip) {
        if let style = sdChip.style {
            backgroundColor = UIColor(hex: style.backgroundColor)
        }
        setSDText(sdChip.text)
    }
}
