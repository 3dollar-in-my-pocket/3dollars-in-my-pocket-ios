import UIKit

import Common
import DesignSystem
import Model

final class FeedCellContentOnlyBodyView: BaseView {
    enum Layout {
        static let verticalPadding: CGFloat = 10
        static let contentLeadingImageWidth: CGFloat = 20
        static let contentLineHeight: CGFloat = 20

        static func calculateHeight(body: ContentOnlyFeedBodyResponse) -> CGFloat {
            var width = UIUtils.windowBounds.width - 88
            if body.contentLeadingImage != nil {
                width -= contentLeadingImageWidth
            }
            let label = makeContentLabel()
            label.setSDText(body.content, customFont: Fonts.regular.font(size: 14), lineHeight: contentLineHeight)
            let contentHeight = ceil(label.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height)

            return contentHeight + verticalPadding * 2
        }

        static func makeContentLabel() -> UILabel {
            let label = UILabel()
            label.font = Fonts.regular.font(size: 14)
            label.textColor = Colors.gray80.color
            label.numberOfLines = 0
            label.textAlignment = .left
            return label
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()
    
    private let contentLeadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let contentLabel = Layout.makeContentLabel()
    
    override func setup() {
        layer.cornerRadius = 12
        layer.masksToBounds = true
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(Layout.verticalPadding)
            $0.bottom.equalToSuperview().offset(-Layout.verticalPadding)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
    }
    
    func bind(body: ContentOnlyFeedBodyResponse) {
        if let contentLeadingImage = body.contentLeadingImage {
            contentLeadingImageView.setImage(urlString: contentLeadingImage.imageUrl)
            stackView.addArrangedSubview(contentLeadingImageView)
            contentLeadingImageView.snp.makeConstraints {
                $0.size.equalTo(16)
            }
        }
        
        contentLabel.setSDText(
            body.content,
            customFont: Fonts.regular.font(size: 14),
            lineHeight: Layout.contentLineHeight
        )
        stackView.addArrangedSubview(contentLabel)
        backgroundColor = UIColor(hex: body.style.backgroundColor)
    }
}
