import UIKit

import Common
import DesignSystem
import Model

final class BookmarkViewerOverviewCell: BaseCollectionViewCell {
    enum Layout {
        static let estimatedHeight: CGFloat = 140
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 24)
        label.textColor = Colors.systemWhite.color
        
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray0.color
        
        return label
    }()
    
    private let medalView: Badge = {
        let badge = Badge(style: .pink)
        badge.isIconHidden = false
        badge.customBackgroundColor = Colors.gray90.color
        return badge
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray70.color
        
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        
        view.backgroundColor = Colors.gray90.color
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        medalView.iconView.clear()
    }
    
    override func setup() {
        addSubViews([
            titleLabel,
            nicknameLabel,
            medalView,
            descriptionLabel,
            divider
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(12)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
        
        medalView.snp.makeConstraints {
            $0.centerY.equalTo(nicknameLabel)
            $0.leading.equalTo(nicknameLabel.snp.trailing).offset(4)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(medalView.snp.bottom).offset(12)
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            $0.height.equalTo(1)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bind(uiModel: UIModel) {
        titleLabel.text = uiModel.title
        descriptionLabel.text = uiModel.description
        nicknameLabel.text = uiModel.user.name
        medalView.iconView.setImage(urlString: uiModel.user.medal.iconUrl)
        medalView.text = uiModel.user.medal.name
    }
}

extension BookmarkViewerOverviewCell {
    struct UIModel: Hashable, Equatable {
        let title: String
        let description: String
        let user: UserResponse
        
        static func == (lhs: BookmarkViewerOverviewCell.UIModel, rhs: BookmarkViewerOverviewCell.UIModel) -> Bool {
            return lhs.title == rhs.title && lhs.description == rhs.description
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(description)
        }
    }
}
