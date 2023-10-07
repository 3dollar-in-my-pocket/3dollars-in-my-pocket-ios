import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailMedalBadgeView: BaseView {
    enum Layout {
        static let height: CGFloat = 20
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.pink100.color
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        return stackView
    }()
    
    private let badgeImgaeView = UIImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.mainPink.color
        label.font = Fonts.medium.font(size: 10)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return label
    }()
    
    override func setup() {
        stackView.addArrangedSubview(badgeImgaeView)
        stackView.addArrangedSubview(titleLabel)
        
        addSubViews([
            containerView,
            stackView
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalTo(stackView).offset(4)
            $0.bottom.equalTo(stackView).offset(4)
        }
        
        stackView.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(4)
            $0.top.equalTo(containerView).offset(4)
        }
        
        badgeImgaeView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
        
        snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
    }
    
    func bind(_ medal: Medal) {
        badgeImgaeView.setImage(urlString: medal.iconUrl)
        titleLabel.text = medal.name
    }
}
