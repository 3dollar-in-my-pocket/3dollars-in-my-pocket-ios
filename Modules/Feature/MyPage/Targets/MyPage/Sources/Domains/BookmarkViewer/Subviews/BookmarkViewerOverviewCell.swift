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
    
    private let medalView = MedalView()
    
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
        
        medalView.prepareForReuse()
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
        medalView.bind(uiModel.user.medal)
    }
}

extension BookmarkViewerOverviewCell {
    struct UIModel: Hashable, Equatable {
        let title: String
        let description: String
        let user: UserApiResponse
        
        static func == (lhs: BookmarkViewerOverviewCell.UIModel, rhs: BookmarkViewerOverviewCell.UIModel) -> Bool {
            return lhs.title == rhs.title && lhs.description == rhs.description
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(title)
            hasher.combine(description)
        }
    }
}


final class MedalView: BaseView {
    private enum Layout {
        static let height: CGFloat = 20
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray90.color
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let medalImage = UIImageView()
    
    private let medalTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 10)
        label.textColor = Colors.mainPink.color
        
        return label
    }()
    
    override func setup() {
        addSubViews([
            containerView,
            medalImage,
            medalTitleLabel
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(medalTitleLabel).offset(4)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(Layout.height)
        }
        
        medalImage.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.centerY.equalTo(containerView)
            $0.leading.equalTo(containerView).offset(4)
        }
        
        medalTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(medalImage.snp.trailing).offset(2)
            $0.centerY.equalTo(medalImage)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(containerView).priority(.required)
        }
    }
    
    func bind(_ medal: MedalResponse) {
        medalImage.setImage(urlString: medal.iconUrl)
        medalTitleLabel.text = medal.name
    }
    
    func prepareForReuse() {
        medalImage.clear()
    }
}
