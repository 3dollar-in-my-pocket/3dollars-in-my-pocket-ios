import UIKit

import Common
import DesignSystem

final class BossStoreDetailReviewHeaderView: BaseCollectionViewReusableView {
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
        return button
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.gray100.color
        
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let stackLastView = verticalStackView.arrangedSubviews.last,
           stackLastView == descriptionLabel {
            stackLastView.removeFromSuperview()
        }
        
        descriptionLabel.text = nil
        valueLabel.text = nil
        rightButton.setTitle(nil, for: .normal)
    }
    
    override func setup() {
        verticalStackView.addArrangedSubview(titleLabel)
        addSubViews([
            verticalStackView,
            rightButton,
            valueLabel
        ])
    }
    
    override func bindConstraints() {
        verticalStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(verticalStackView)
            $0.height.equalTo(18)
        }
        
        valueLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing)
            $0.centerY.equalTo(titleLabel)
        }
    }
    
    func bind(_ header: StoreDetailSectionHeader?) {
        guard let header else { return }
        titleLabel.text = header.title
        verticalStackView.addArrangedSubview(titleLabel)
        
        if let description = header.description {
            verticalStackView.setCustomSpacing(2, after: titleLabel)
            verticalStackView.addArrangedSubview(descriptionLabel)
            descriptionLabel.text = description
        }
        
        rightButton.setTitle(header.buttonTitle, for: .normal)
        
        if let value = header.value {
            valueLabel.text = value
        }
    }
}
