import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailHeaderView: BaseView {
    enum Layout {
        static func calculateHeight(header: HeaderSectionResponse) -> CGFloat {
            if header.subTitle.isNil {
                return 24
            } else {
                return 44
            }
        }
    }
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        return stackView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray60.color
        return label
    }()
    
    let rightButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        button.setTitleColor(Colors.mainPink.color, for: .normal)
        return button
    }()
    
    override func setup() {
        setupUI()
    }
    
    func prepareForReuse() {
        verticalStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        subtitleLabel.text = nil
    }
    
    private func setupUI() {
        addSubViews([
            verticalStackView,
            rightButton
        ])
        
        verticalStackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(verticalStackView)
            $0.height.equalTo(18)
        }
    }
    
    func bind(header: HeaderSectionResponse) {
        titleLabel.setSDText(header.title)
        verticalStackView.addArrangedSubview(titleLabel)
        
        if let subTitle = header.subTitle {
            subtitleLabel.setSDText(subTitle)
            verticalStackView.addArrangedSubview(subtitleLabel)
        }
        
        if let rightButton = header.rightButton {
            self.rightButton.setSDButton(rightButton)
        }
    }
}
