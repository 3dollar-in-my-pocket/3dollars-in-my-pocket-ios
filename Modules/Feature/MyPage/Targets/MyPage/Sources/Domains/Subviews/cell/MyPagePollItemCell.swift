import UIKit

import Common
import DesignSystem
import SnapKit
import Then
import Model

final class MyPagePollItemCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 20 + 126 + 8
        static let optionHeight: CGFloat = 90
    }
    
    private let containerView = UIView().then {
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.gray95.color
        $0.layer.cornerRadius = 16
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 24)
        $0.textColor = Colors.gray10.color
    }
    
    private let dateLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray10.color
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 12
    }
    
    private let firstOptionView = MyPagePollOptionView()
    private let secondOptionView = MyPagePollOptionView()
    
    override func setup() {
        super.setup()
        
        contentView.addSubViews([
            containerView
        ])
        
        containerView.addSubViews([
            titleLabel,
            dateLabel,
            stackView
        ])
        
        stackView.addArrangedSubview(firstOptionView)
        stackView.addArrangedSubview(secondOptionView)
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(dateLabel.snp.leading).offset(-8)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    func bind(_ data: PollApiResponse, isFirst: Bool, isLast: Bool) {
        titleLabel.text = data.content.title
        dateLabel.text = DateUtils.toString(dateString: data.updatedAt, format: "yyyy.MM.dd")
        
        if let firstOption = data.options[safe: 0], let secondOption = data.options[safe: 1] {
            firstOptionView.bind(
                item: firstOption, 
                isHighlighted: firstOption.choice.count > secondOption.choice.count
            )
            secondOptionView.bind(
                item: secondOption, 
                isHighlighted: secondOption.choice.count > firstOption.choice.count
            )
        }
        
        setMaskedCorners(isFirst: isFirst, isLast: isLast)
    }
    
    private func setMaskedCorners(isFirst: Bool, isLast: Bool) {
        var maskedCorners: CACornerMask {
            if isFirst {
                [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if isLast {
                [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                []
            }
        }
        
        containerView.layer.maskedCorners = maskedCorners
    }
}

final private class MyPagePollOptionView: BaseView {
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Colors.gray70.color.cgColor
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.systemWhite.color
        $0.numberOfLines = 2
        $0.textAlignment = .left
    }
    
    private let emojiLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
    }
    
    private let percentLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
    }
    
    private let countLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 10)
    }
    
    override func setup() {
        super.setup()
        
        addSubViews([
            containerView
        ])
        
        containerView.addSubViews([
            titleLabel,
            emojiLabel,
            percentLabel,
            countLabel
        ])
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        emojiLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(10)
        }
        
        percentLabel.snp.makeConstraints {
            $0.leading.equalTo(emojiLabel.snp.trailing).offset(2)
            $0.bottom.equalToSuperview().inset(10)
        }
        
        countLabel.snp.makeConstraints {
            $0.leading.equalTo(percentLabel.snp.trailing).offset(2)
            $0.centerY.equalTo(emojiLabel)
        }
    }
    
    func bind(item: PollOptionWithChoiceApiResponse, isHighlighted: Bool) {
        titleLabel.text = item.name
        percentLabel.text = "\(Int(item.choice.ratio * 100))%"
        countLabel.text = "\(item.choice.count)명"
        
        emojiLabel.text = isHighlighted ? "🤣" : "😞"
        containerView.layer.borderColor = isHighlighted ? Colors.mainRed.color.cgColor : Colors.gray70.color.cgColor
        titleLabel.textColor = isHighlighted ? Colors.systemWhite.color : Colors.gray60.color
        percentLabel.textColor = isHighlighted ? Colors.systemWhite.color : Colors.gray60.color
        countLabel.textColor = isHighlighted ? Colors.gray50.color : Colors.gray70.color
    }
}
