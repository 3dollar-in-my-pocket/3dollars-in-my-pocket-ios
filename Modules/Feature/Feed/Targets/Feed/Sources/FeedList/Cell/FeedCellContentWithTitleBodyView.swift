import UIKit

import Common
import DesignSystem
import Model

final class FeedCellContentWithTitleBodyView: BaseView {
    enum Layout {
        static let padding: CGFloat = 12
        static let titleRowHeight: CGFloat = StarBadgeView.Layout.size.height
        static let contentSpacing: CGFloat = 8
        static let contentLineHeight: CGFloat = 20
        static let contentMaxLines = 5

        static func calculateHeight(body: ContentWithTitleFeedBodyResponse) -> CGFloat {
            let width = UIUtils.windowBounds.width - 32 - padding * 2
            let contentHeight = measureContentHeight(body.content, width: width)

            return padding + titleRowHeight + contentSpacing + contentHeight + padding
        }

        private static func measureContentHeight(_ content: SDText, width: CGFloat) -> CGFloat {
            let label = makeContentLabel()
            label.setSDText(content, customFont: Fonts.regular.font(size: 14), lineHeight: contentLineHeight)
            return ceil(label.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height)
        }

        static func makeContentLabel() -> UILabel {
            let label = UILabel()
            label.font = Fonts.regular.font(size: 14)
            label.textColor = Colors.gray80.color
            label.numberOfLines = contentMaxLines
            return label
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 12)
        
        return label
    }()
    
    private let starBadgeView = StarBadgeView()
    
    private let contentLabel = Layout.makeContentLabel()
    
    override func setup() {
        backgroundColor = Colors.gray0.color
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        addSubViews([
            titleLabel,
            starBadgeView,
            contentLabel
        ])
        
        starBadgeView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.padding)
            $0.trailing.equalToSuperview().offset(-Layout.padding)
            $0.size.equalTo(StarBadgeView.Layout.size)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.padding)
            $0.centerY.equalTo(starBadgeView)
            $0.trailing.lessThanOrEqualTo(starBadgeView.snp.leading).offset(-Layout.padding)
        }

        contentLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.padding)
            $0.trailing.equalToSuperview().offset(-Layout.padding)
            $0.top.equalTo(starBadgeView.snp.bottom).offset(Layout.contentSpacing)
            $0.bottom.lessThanOrEqualToSuperview().offset(-Layout.padding)
        }
    }
    
    func bind(body: ContentWithTitleFeedBodyResponse) {
        titleLabel.setSDText(body.title)
        
        if let rating = body.additionalInfos?.rating?.starRating {
            starBadgeView.bind(Int(rating))
        }
        
        contentLabel.setSDText(
            body.content,
            customFont: Fonts.regular.font(size: 14),
            lineHeight: Layout.contentLineHeight
        )
        backgroundColor = UIColor(hex: body.style.backgroundColor)
    }
    
}
