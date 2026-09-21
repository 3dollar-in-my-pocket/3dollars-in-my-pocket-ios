import UIKit

import Common
import DesignSystem

final class PolicyView: Common.BaseView {
    let backgroundButton = UIButton()
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 24
        containerView.backgroundColor = Colors.gray90.color
        return containerView
    }()
    
    let allCheckButton: UIButton = {
        let allCheckButton = UIButton()
        allCheckButton.setImage(Assets.icCheckSolidOn.image, for: .selected)
        allCheckButton.setImage(Assets.icCheckSolidOff.image, for: .normal)
        allCheckButton.setTitle(Strings.policyAgreeAll, for: .normal)
        allCheckButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        allCheckButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        allCheckButton.titleLabel?.font = Fonts.bold.font(size: 16)
        allCheckButton.setTitleColor(Colors.systemWhite.color, for: .normal)
        return allCheckButton
    }()
    
    private let dividerView: UIView = {
        let dividerView = UIView()
        dividerView.backgroundColor = Colors.gray80.color
        return dividerView
    }()
    
    let policyCheckButton: UIButton = {
        let policyCheckButton = UIButton()
        policyCheckButton.setImage(Assets.icCheckSolidOn.image, for: .selected)
        policyCheckButton.setImage(Assets.icCheckSolidOff.image, for: .normal)
        policyCheckButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        policyCheckButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        policyCheckButton.setTitle(Strings.policyPolicyLabel, for: .normal)
        policyCheckButton.titleLabel?.font = Fonts.regular.font(size: 14)
        policyCheckButton.setTitleColor(Colors.systemWhite.color, for: .normal)
        return policyCheckButton
    }()
    
    let policyButton: UIButton = {
        let policyButton = UIButton()
        policyButton.setImage(
            Icons.arrowRight.image.withTintColor(Colors.gray70.color),
            for: .normal
        )
        return policyButton
    }()
    
    let marketingCheckButton: UIButton = {
        let marketingCheckButton = UIButton()
        marketingCheckButton.setImage(Assets.icCheckSolidOn.image, for: .selected)
        marketingCheckButton.setImage(Assets.icCheckSolidOff.image, for: .normal)
        marketingCheckButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        marketingCheckButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        marketingCheckButton.setTitle(Strings.policyMarketingLabel, for: .normal)
        marketingCheckButton.titleLabel?.font = Fonts.regular.font(size: 14)
        marketingCheckButton.setTitleColor(Colors.systemWhite.color, for: .normal)
        return marketingCheckButton
    }()
    
    let marketingButton: UIButton = {
        let marketingButton = UIButton()
        marketingButton.setImage(
            Icons.arrowRight.image.withTintColor(Colors.gray70.color),
            for: .normal
        )
        return marketingButton
    }()
    
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
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(containerView.snp.top)
        }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(allCheckButton).offset(-24)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(20)
            $0.trailing.equalTo(containerView).offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }
        
        marketingButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(16)
            $0.bottom.equalTo(nextButton.snp.top).offset(-42)
        }
        
        marketingCheckButton.snp.makeConstraints {
            $0.centerY.equalTo(marketingButton)
            $0.leading.equalToSuperview().offset(20)
        }
        
        policyCheckButton.snp.makeConstraints {
            $0.bottom.equalTo(marketingCheckButton.snp.top).offset(-28)
            $0.leading.equalToSuperview().offset(20)
        }
        
        policyButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(16)
            $0.centerY.equalTo(policyCheckButton)
        }
        
        dividerView.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(policyCheckButton.snp.top).offset(-24)
        }
        
        allCheckButton.snp.makeConstraints {
            $0.leading.equalTo(marketingCheckButton)
            $0.bottom.equalTo(dividerView.snp.top).offset(-18)
        }
    }
}
