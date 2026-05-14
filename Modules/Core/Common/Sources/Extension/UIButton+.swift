import UIKit

import Model
import ZMarkupParser
import Kingfisher

public extension UIButton {
    func setSDButton(_ sdButton: SDButton) {
        if let sdText = sdButton.text {
            setTitleColor(UIColor(hex: sdText.fontColor), for: .normal)

            if sdText.isHtml {
                let attributedText = ZHTMLParserBuilder.initWithDefault().build().render(sdText.text)
                setAttributedTitle(attributedText, for: .normal)
            } else {
                setTitle(sdText.text, for: .normal)
            }
        } else {
            setAttributedTitle(nil, for: .normal)
            setTitle(nil, for: .normal)
        }

        if let image = sdButton.image,
           let imageUrl = URL(string: image.url),
           isValidImageSize(width: image.style.width, height: image.style.height) {
            let resizeProcessor = ResizingImageProcessor(
                referenceSize: CGSize(width: image.style.width, height: image.style.height),
                mode: .aspectFit
            )

            DispatchQueue.main.async { [weak self] in
                self?.kf.setImage(with: imageUrl, for: .normal, options: [.processor(resizeProcessor)])
            }
        }

        backgroundColor = UIColor(hex: sdButton.style.backgroundColor)
    }

    private func isValidImageSize(width: Double, height: Double) -> Bool {
        let maxSize: Double = 10000
        let minSize: Double = 1

        guard !width.isNaN && !width.isInfinite && !height.isNaN && !height.isInfinite else {
            return false
        }

        guard width >= minSize && width <= maxSize && height >= minSize && height <= maxSize else {
            return false
        }

        return true
    }
}
