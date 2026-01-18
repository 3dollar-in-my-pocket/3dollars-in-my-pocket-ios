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
        text = sdText.text

        if let color = UIColor(hex: sdText.style.fontColor) {
            textColor = color
        }

        if let fontSize = sdText.style.fontSize {
            let fontWeight = fontWeight(from: sdText.style.fontWeight)
            font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: fontWeight)
        }
    }

    private func fontWeight(from weight: String?) -> UIFont.Weight {
        guard let weight else { return .regular }

        switch weight.lowercased() {
        case "bold":
            return .bold
        case "semibold":
            return .semibold
        case "medium":
            return .medium
        case "light":
            return .light
        default:
            return .regular
        }
    }
}
