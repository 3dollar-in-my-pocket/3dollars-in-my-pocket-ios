import UIKit

import Common
import DesignSystem
import Model

final class FeedCellContentWithTitleBodyView: BaseView {
    enum Layout {
        static func calculateHeight(body: ContentWithTitleFeedBodyResponse) -> CGFloat {
            let width = UIUtils.windowBounds.width - 56
            let contentHeight = body.content.text.height(font: Fonts.regular.font(size: 14), width: width)
            
            return contentHeight + 52
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 12)
        
        return label
    }()
    
    private let starBadgeView = StarBadgeView()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray80.color
        label.numberOfLines = 5
        return label
    }()
    
    override func setup() {
        backgroundColor = Colors.gray0.color
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        addSubViews([
            titleLabel,
            starBadgeView,
            contentLabel
        ])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(13)
            $0.trailing.lessThanOrEqualTo(starBadgeView.snp.leading).offset(-12)
        }
        
        starBadgeView.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-12)
            $0.size.equalTo(StarBadgeView.Layout.size)
        }
        
        contentLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
            $0.top.equalTo(starBadgeView.snp.bottom).offset(8)
        }
    }
    
    func bind(body: ContentWithTitleFeedBodyResponse) {
        titleLabel.setUiText(body.title)
        
        if let rating = body.additionalInfos?.rating?.starRating {
            starBadgeView.bind(Int(rating))
        }
        
        contentLabel.setUiText(body.content)
        backgroundColor = UIColor(hex: body.style.backgroundColor)
    }
    
}
