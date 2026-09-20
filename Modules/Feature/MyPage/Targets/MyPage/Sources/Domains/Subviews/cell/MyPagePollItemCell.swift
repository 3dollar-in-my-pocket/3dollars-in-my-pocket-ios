import UIKit

import Common
import DesignSystem
import SnapKit
import Model

final class MyPagePollItemCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 20 + 126 + 8
        static let optionHeight: CGFloat = 90
    }
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.clipsToBounds = true
        containerView.backgroundColor = Colors.gray95.color
        containerView.layer.cornerRadius = 16
        return containerView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.bold.font(size: 24)
        titleLabel.textColor = Colors.gray10.color
        return titleLabel
    }()
    
    private let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = Fonts.medium.font(size: 12)
        dateLabel.textColor = Colors.gray10.color
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        return dateLabel
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()
    
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
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = Colors.gray70.color.cgColor
        return containerView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.medium.font(size: 12)
        titleLabel.textColor = Colors.systemWhite.color
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        return titleLabel
    }()
    
    private let emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.font = Fonts.bold.font(size: 16)
        return emojiLabel
    }()
    
    private let percentLabel: UILabel = {
        let percentLabel = UILabel()
        percentLabel.font = Fonts.bold.font(size: 16)
        return percentLabel
    }()
    
    private let countLabel: UILabel = {
        let countLabel = UILabel()
        countLabel.font = Fonts.medium.font(size: 10)
        return countLabel
    }()
    
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
