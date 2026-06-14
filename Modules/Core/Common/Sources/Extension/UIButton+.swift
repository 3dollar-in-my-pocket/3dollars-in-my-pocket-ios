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

        if let backgroundColor = UIColor(hex: sdButton.style.backgroundColor) {
            self.backgroundColor = backgroundColor
        }

        if let border = sdButton.style.border {
            layer.borderColor = UIColor(hex: border.color)?.cgColor
            layer.borderWidth = CGFloat(border.width)
        } else {
            layer.borderColor = nil
            layer.borderWidth = 0
        }

        // 아이콘-텍스트 간격 4pt. forceRightToLeft 일 때는 left/right 가 자동 반전되지 않으므로
        // 정렬에 맞춰 inset 의 좌우 값을 직접 뒤집어 음수 간격이 생기는 것을 방지한다.
        let spacing: CGFloat = 4
        let halfSpacing = spacing / 2
        switch sdButton.imageAlignment {
        case .end:
            semanticContentAttribute = .forceRightToLeft
            titleEdgeInsets = UIEdgeInsets(top: 0, left: -halfSpacing, bottom: 0, right: halfSpacing)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: halfSpacing, bottom: 0, right: -halfSpacing)
        case .start, .unknown, .none:
            semanticContentAttribute = .unspecified
            titleEdgeInsets = UIEdgeInsets(top: 0, left: halfSpacing, bottom: 0, right: -halfSpacing)
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -halfSpacing, bottom: 0, right: halfSpacing)
        }
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
