import UIKit

import Model
import ZMarkupParser
import Kingfisher

public extension UIButton {
    func clear() {
        kf.cancelImageDownloadTask()
        setImage(nil, for: .normal)
        setAttributedTitle(nil, for: .normal)
        setTitle(nil, for: .normal)

        if var config = configuration {
            config.image = nil
            config.title = nil
            config.attributedTitle = nil
            configuration = config
        }
    }

    func setSDButton(_ sdButton: SDButton) {
        if let sdText = sdButton.text {
            setTitleColor(UIColor(hex: sdText.fontColor), for: .normal)

            if sdText.isHtml {
                let baseFont = titleLabel?.font
                var parser = ZHTMLParserBuilder.initWithDefault()
                if let baseFont {
                    parser = parser.set(rootStyle: MarkupStyle(font: MarkupStyleFont(baseFont)))
                }
                let rendered = parser.build().render(sdText.text)
                let attributedText = baseFont.map { rendered.applyingFontFamily(of: $0) } ?? rendered
                setAttributedTitle(attributedText, for: .normal)
            } else {
                setTitle(sdText.text, for: .normal)
            }
        } else {
            setAttributedTitle(nil, for: .normal)
            setTitle(nil, for: .normal)
        }

        kf.cancelImageDownloadTask()
        if let image = sdButton.image,
           let imageUrl = URL(string: image.url),
           isValidImageSize(width: image.style.width, height: image.style.height) {
            let downsamplingProcessor = DownsamplingImageProcessor(
                size: CGSize(width: image.style.width, height: image.style.height)
            )
            kf.setImage(
                with: imageUrl,
                for: .normal,
                options: [.processor(downsamplingProcessor), .scaleFactor(UIScreen.main.scale)]
            )
        } else {
            setImage(nil, for: .normal)
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
