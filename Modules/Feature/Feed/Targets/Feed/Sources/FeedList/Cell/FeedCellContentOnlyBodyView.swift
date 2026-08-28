import UIKit

import Common
import DesignSystem
import Model
import ZMarkupParser

final class FeedCellContentOnlyBodyView: BaseView {
    enum Layout {
        static let verticalPadding: CGFloat = 10
        static let contentLeadingImageWidth: CGFloat = 20

        static func calculateHeight(body: ContentOnlyFeedBodyResponse) -> CGFloat {
            // 셀(-32) + FeedCell 스택 마진(-32) + 좌우 패딩(-24) 을 제외한 실제 텍스트 폭
            var width = UIUtils.windowBounds.width - 88
            if body.contentLeadingImage != nil {
                width -= contentLeadingImageWidth
            }
            let contentHeight: CGFloat
            if body.content.isHtml {
                contentHeight = ZHTMLParserBuilder.initWithDefault().build().render(body.content.text).height(width: width)
            } else {
                contentHeight = body.content.text.height(font: Fonts.regular.font(size: 14), width: width)
            }

            return contentHeight + verticalPadding * 2
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
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray80.color
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
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
        
        contentLabel.setSDText(body.content)
        stackView.addArrangedSubview(contentLabel)
        backgroundColor = UIColor(hex: body.style.backgroundColor)
    }
}
