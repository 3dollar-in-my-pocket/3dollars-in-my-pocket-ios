import UIKit

import Common
import DesignSystem

final class PolicyView: Common.BaseView {
    let backgroundButton = UIButton()
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 24
        $0.backgroundColor = Colors.gray90.color
    }
    
    let allCheckButton = UIButton().then {
        $0.setImage(Assets.icCheckSolidOn.image, for: .selected)
        $0.setImage(Assets.icCheckSolidOff.image, for: .normal)
        $0.setTitle(Strings.policyAgreeAll, for: .normal)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        $0.titleLabel?.font = Fonts.bold.font(size: 16)
        $0.setTitleColor(Colors.systemWhite.color, for: .normal)
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = Colors.gray80.color
    }
    
    let policyCheckButton = UIButton().then {
        $0.setImage(Assets.icCheckSolidOn.image, for: .selected)
        $0.setImage(Assets.icCheckSolidOff.image, for: .normal)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        $0.setTitle(Strings.policyPolicyLabel, for: .normal)
        $0.titleLabel?.font = Fonts.regular.font(size: 14)
        $0.setTitleColor(Colors.systemWhite.color, for: .normal)
    }
    
    let policyButton = UIButton().then {
        $0.setImage(
            Icons.arrowRight.image.withTintColor(Colors.gray70.color),
            for: .normal
        )
    }
    
    let marketingCheckButton = UIButton().then {
        $0.setImage(Assets.icCheckSolidOn.image, for: .selected)
        $0.setImage(Assets.icCheckSolidOff.image, for: .normal)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        $0.setTitle(Strings.policyMarketingLabel, for: .normal)
        $0.titleLabel?.font = Fonts.regular.font(size: 14)
        $0.setTitleColor(Colors.systemWhite.color, for: .normal)
    }
    
    let marketingButton = UIButton().then {
        $0.setImage(
            Icons.arrowRight.image.withTintColor(Colors.gray70.color),
            for: .normal
        )
    }
    
    let nextButton = Button.Normal(size: .h48, text: Strings.policyNextButton)
    
    override func setup() {
        addSubViews([
            backgroundButton,
            containerView,
            allCheckButton,
            dividerView,
            policyCheckButton,
            policyButton,
            marketingCheckButton,
            marketingButton,
            nextButton
        ])
    }
    
    override func bindConstraints() {
        backgroundButton.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(containerView.snp.top)
        }
        
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(allCheckButton).offset(-24)
        }
        
        nextButton.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(20)
            $0.right.equalTo(containerView).offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }
        
        marketingButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.width.height.equalTo(16)
            $0.bottom.equalTo(nextButton.snp.top).offset(-42)
        }
        
        marketingCheckButton.snp.makeConstraints {
            $0.centerY.equalTo(marketingButton)
            $0.left.equalToSuperview().offset(20)
        }
        
        policyCheckButton.snp.makeConstraints {
            $0.bottom.equalTo(marketingCheckButton.snp.top).offset(-28)
            $0.left.equalToSuperview().offset(20)
        }
        
        policyButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.width.height.equalTo(16)
            $0.centerY.equalTo(policyCheckButton)
        }
        
        dividerView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalTo(policyCheckButton.snp.top).offset(-24)
        }
        
        allCheckButton.snp.makeConstraints {
            $0.left.equalTo(marketingCheckButton)
            $0.bottom.equalTo(dividerView.snp.top).offset(-18)
        }
    }
}
