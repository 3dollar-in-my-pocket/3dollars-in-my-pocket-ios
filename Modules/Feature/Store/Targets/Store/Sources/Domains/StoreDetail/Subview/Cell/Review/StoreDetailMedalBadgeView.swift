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
        stackView.alignment = .center
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
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
        }
        
        badgeImgaeView.snp.makeConstraints {
            $0.size.equalTo(16)
        }
    }
    
    func prepareForReuse() {
        badgeImgaeView.clear()
        titleLabel.text = nil
    }
    
    func bind(_ medal: Medal) {
        badgeImgaeView.setImage(urlString: medal.iconUrl)
        titleLabel.text = medal.name
    }
}
