import UIKit

import SnapKit

import Common
import DesignSystem
import Model

final class BossStoreCouponView: BaseView {
    
    enum Layout {
        static func size(width: CGFloat, viewModel: BossStoreCouponViewModel) -> CGSize {
            var totalHeight: CGFloat = 0
            var contentHeight: CGFloat = 0
            let minContentHeight: CGFloat = 80
           
            // content
            let textWidth = width - 40 - 106
            let titleHeight = viewModel.output.title.height(font: Fonts.bold.font(size: 16), width: textWidth)
            let dateHeight = viewModel.output.date.height(font: Fonts.regular.font(size: 14), width: textWidth)
            contentHeight += 16
            contentHeight += titleHeight
            contentHeight += 4
            contentHeight += dateHeight
            contentHeight += 16
            contentHeight = max(minContentHeight, contentHeight)
            
            switch viewModel.output.couponStatus.value {
            case .issuable, .issued:
                totalHeight += 18
            case .expired, .used:
                break
            }
            
            totalHeight += contentHeight
            
            return CGSize(width: width, height: totalHeight)
        }
    }
    private let contentView = UIView()
    
    private let backgroundImageView = UIImageView().then {
        $0.image = Assets.couponBackground.image
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray80.color
        $0.numberOfLines = 2
        $0.lineBreakMode = .byTruncatingTail
    }

    private let dateLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 14)
        $0.textColor = Colors.gray70.color
    }

    private let rightIconImageView = UIImageView().then {
        $0.image = Assets.arrowRight.image
    }
    
    private let rightTextLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = Colors.gray60.color
        $0.numberOfLines = 2
        $0.textAlignment = .center
    }
    
    private let rightButton = UIButton().then {
        $0.setTitle(nil, for: .normal)
        $0.backgroundColor = .clear
    }
    
    private let dashedBorderLineView = UIImageView().then {
        $0.image = Assets.couponDot.image.withTintColor(UIColor(hex: "#BC4BD6")!)
    }

    private let deadlineLabel = PaddingLabel(
        topInset: 4,
        bottomInset: 4,
        leftInset: 8,
        rightInset: 8
    ).then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.mainPink.color
        $0.backgroundColor = Colors.gray90.color
        $0.layer.cornerRadius = 13
        $0.clipsToBounds = true
    }
    
    private var contentViewTopConstraints: Constraint?
    
    override func setup() {
        super.setup()

        backgroundColor = .clear

        addSubViews([
            contentView,
            deadlineLabel
        ])
        
        contentView.addSubViews([
            backgroundImageView,
            stackView,
            dashedBorderLineView,
            rightIconImageView,
            rightTextLabel,
            rightButton
        ])
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(dateLabel)
        
        dashedBorderLineView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        deadlineLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }

    override func bindConstraints() {
        super.bindConstraints()
        
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        rightIconImageView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 30, height: 30))
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(25)
        }
        rightTextLabel.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 30, height: 40))
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(25)
        }
        dashedBorderLineView.snp.makeConstraints {
            $0.trailing.equalTo(rightIconImageView.snp.leading).offset(-16)
            $0.top.bottom.equalToSuperview().inset(12)
            $0.width.equalTo(1)
        }
        rightButton.snp.makeConstraints {
            $0.leading.equalTo(dashedBorderLineView.snp.trailing)
            $0.top.bottom.trailing.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            self.contentViewTopConstraints = $0.top.equalToSuperview().inset(18).constraint
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        deadlineLabel.snp.makeConstraints {
            $0.leading.equalTo(contentView.snp.leading).offset(12)
            $0.bottom.equalTo(contentView.snp.top).offset(8)
            $0.height.equalTo(26)
        }
        stackView.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(18)
            $0.trailing.equalTo(dashedBorderLineView.snp.leading).offset(-16)
            $0.bottom.lessThanOrEqualToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
    
    func bind(viewModel: BossStoreCouponViewModel) {
        cancellables.removeAll()
        
        deadlineLabel.text = viewModel.output.deadline
        titleLabel.text = viewModel.output.title
        titleLabel.lineBreakMode = .byTruncatingTail
        dateLabel.text = viewModel.output.date
        rightIconImageView.isHidden = viewModel.output.isRightViewHidden
        rightButton.isHidden = viewModel.output.isRightViewHidden
        rightTextLabel.isHidden = viewModel.output.isRightViewHidden
        
        viewModel.output.couponStatus
            .main
            .withUnretained(self)
            .sink { (owner: BossStoreCouponView, status: BossStoreCouponViewModel.CouponStatus) in
                switch status {
                case .issuable:
                    owner.rightIconImageView.image = Assets.download.image
                    owner.titleLabel.textColor = Colors.gray80.color
                    owner.dateLabel.textColor = Colors.gray70.color
                    owner.deadlineLabel.isHidden = false
                    owner.contentViewTopConstraints?.update(offset: 18)
                    if viewModel.output.isRightViewHidden.isNot {
                        owner.rightIconImageView.isHidden = false
                        owner.rightTextLabel.isHidden = true
                    }
                case .issued:
                    owner.rightIconImageView.image =  Assets.arrowRight.image
                    owner.titleLabel.textColor = Colors.gray80.color
                    owner.dateLabel.textColor = Colors.gray70.color
                    owner.deadlineLabel.isHidden = false
                    owner.contentViewTopConstraints?.update(offset: 18)
                    if viewModel.output.isRightViewHidden.isNot {
                        owner.rightIconImageView.isHidden = false
                        owner.rightTextLabel.isHidden = true
                    }
                case .used:
                    owner.rightTextLabel.text = "사용완료"
                    owner.titleLabel.textColor = Colors.gray60.color
                    owner.dateLabel.textColor = Colors.gray60.color
                    owner.deadlineLabel.isHidden = true
                    owner.contentViewTopConstraints?.update(inset: 0)
                    if viewModel.output.isRightViewHidden.isNot {
                        owner.rightIconImageView.isHidden = true
                        owner.rightTextLabel.isHidden = false
                    }
                    if viewModel.output.fromMyCoupons {
                        owner.dashedBorderLineView.image = Assets.couponDot.image.withTintColor(Colors.gray70.color)
                        owner.backgroundImageView.image = Assets.couponBackgroundBlack.image
                    } else {
                        owner.backgroundImageView.image = Assets.couponBackground.image
                        owner.dashedBorderLineView.image = Assets.couponDot.image.withTintColor(UIColor(hex: "#BC4BD6")!)
                    }
                case .expired:
                    owner.rightTextLabel.text = "기간만료"
                    owner.titleLabel.textColor = Colors.gray60.color
                    owner.dateLabel.textColor = Colors.gray60.color
                    owner.deadlineLabel.isHidden = true
                    owner.contentViewTopConstraints?.update(inset: 0)
                    if viewModel.output.isRightViewHidden.isNot {
                        owner.rightIconImageView.isHidden = true
                        owner.rightTextLabel.isHidden = false
                    }
                    if viewModel.output.fromMyCoupons {
                        owner.dashedBorderLineView.image = Assets.couponDot.image.withTintColor(Colors.gray70.color)
                        owner.backgroundImageView.image = Assets.couponBackgroundBlack.image
                    } else {
                        owner.backgroundImageView.image = Assets.couponBackground.image
                        owner.dashedBorderLineView.image = Assets.couponDot.image.withTintColor(UIColor(hex: "#BC4BD6")!)
                    }
                }
            }
            .store(in: &cancellables)
        
        rightButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapRightButton)
            .store(in: &cancellables)
    }
}
