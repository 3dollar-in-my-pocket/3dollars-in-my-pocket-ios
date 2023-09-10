import UIKit

import Common
import DesignSystem

final class StoreDetailHeaderView: BaseCollectionViewReusableView {
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        label.text = "가게 정보 & 메뉴"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray60.color
        return label
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        button.setTitleColor(Colors.mainPink.color, for: .normal)
        button.isHidden = true
        return button
    }()
    
    override func setup() {
        verticalStackView.addArrangedSubview(titleLabel)
        addSubViews([
            verticalStackView,
            rightButton
        ])
    }
    
    override func bindConstraints() {
        verticalStackView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
        }
    }
}
