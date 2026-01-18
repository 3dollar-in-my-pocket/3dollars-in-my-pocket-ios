import UIKit

import Model

// MARK: SDU
public extension UIView {
    func setSDSurfaceStyle(_ sdSurfaceStyle: SDSurfaceStyle) {
        backgroundColor = UIColor(hex: sdSurfaceStyle.backgroundColor)

        if let borderColor = sdSurfaceStyle.borderColor,
           let borderWidth = sdSurfaceStyle.borderWidth {
            layer.borderColor = UIColor(hex: borderColor).cgColor
            layer.borderWidth = borderWidth
        }

        if let cornerRadius = sdSurfaceStyle.cornerRadius {
            layer.cornerRadius = cornerRadius
        }
    }
}

public extension UILabel {
    func setSDText(_ sdText: SDText) {
        text = sdText.text
        textColor = UIColor(hex: sdText.style.fontColor)

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
