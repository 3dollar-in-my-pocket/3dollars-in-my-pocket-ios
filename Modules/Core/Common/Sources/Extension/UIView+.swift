import UIKit

import Model

// MARK: SDU
public extension UIView {
    func setSDSurfaceStyle(_ sdSurfaceStyle: SDSurfaceStyle) {
        backgroundColor = UIColor(hex: sdSurfaceStyle.backgroundColor)

        if let borderColor = sdSurfaceStyle.borderColor,
           let borderWidth = sdSurfaceStyle.borderWidth,
           let color = UIColor(hex: borderColor) {
            layer.borderColor = color.cgColor
            layer.borderWidth = borderWidth
        }

        if let cornerRadius = sdSurfaceStyle.cornerRadius {
            layer.cornerRadius = cornerRadius
        }
    }
}
