import UIKit

import Model

import NMapsMap

enum HomeMarkerIcon {
    static func alpha(of style: SDImageStyle?) -> CGFloat {
        guard let alpha = style?.alpha else { return 1.0 }
        return CGFloat(min(max(alpha, 0), 1))
    }
}

extension NMFMarker {
    func applyIcon(_ image: UIImage, style: SDImageStyle) {
        iconImage = NMFOverlayImage(image: image)
        width = style.width
        height = style.height
        alpha = HomeMarkerIcon.alpha(of: style)
    }
}
