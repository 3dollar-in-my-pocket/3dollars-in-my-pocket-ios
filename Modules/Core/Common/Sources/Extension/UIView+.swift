import UIKit

import Model

// MARK: SDU
public extension UIView {
    func setSDSurfaceStyle(_ sdSurfaceStyle: SDSurfaceStyle) {
        backgroundColor = UIColor(hex: sdSurfaceStyle.backgroundColor)

        // 서버 응답: 중첩 border 형태가 표준. flat 형태는 legacy 호출자(예: HomeViewModel.selectedSurface) 호환용.
        if let border = sdSurfaceStyle.border, let color = UIColor(hex: border.color) {
            layer.borderColor = color.cgColor
            layer.borderWidth = border.width
        } else if let borderColor = sdSurfaceStyle.borderColor,
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
