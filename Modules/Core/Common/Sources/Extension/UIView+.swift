import UIKit

import Model

public extension UIView {
    func setSDSurfaceStyle(_ sdSurfaceStyle: SDSurfaceStyle) {
        backgroundColor = UIColor(hex: sdSurfaceStyle.backgroundColor)

        if let border = sdSurfaceStyle.border,
           let color = UIColor(hex: border.color) {
            layer.borderColor = color.cgColor
            layer.borderWidth = border.width
        }
    }
    
    func setSDChipStyle(_ sdChipStyle: SDChipStyle) {
        backgroundColor = UIColor(hex: sdChipStyle.backgroundColor)
        
        if let border = sdChipStyle.border,
           let color = UIColor(hex: border.color) {
            layer.borderColor = color.cgColor
            layer.borderWidth = border.width
        }
    }
}
