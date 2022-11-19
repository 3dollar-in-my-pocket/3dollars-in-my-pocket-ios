import UIKit

final class PolicyView: BaseView {
    let backgroundButton = UIButton()
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 30
        $0.backgroundColor = R.color.gray80()
    }
    
    let allCheckButton = UIButton().then {
        $0.setImage(Icon.Check.generate(isOn: true, style: .solid), for: .selected)
        $0.setImage(Icon.Check.generate(isOn: false, style: .solid), for: .normal)
        $0.setTitle(R.string.localization.policy_agree_all(), for: .normal)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: -12)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        $0.titleLabel?.font = .bold(size: 16)
        $0.setTitleColor(R.color.gray5(), for: .normal)
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = R.color.gray70()
    }
    
    let policyCheckButton = UIButton().then {
        $0.setImage(Icon.Check.generate(isOn: true, style: .line), for: .selected)
        $0.setImage(Icon.Check.generate(isOn: false, style: .line), for: .normal)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        $0.setTitle(R.string.localization.policy_policy_label(), for: .normal)
        $0.titleLabel?.font = .regular(size: 14)
        $0.setTitleColor(R.color.gray5(), for: .normal)
    }
    
    let policyButton = UIButton().then {
        $0.setImage(R.image.ic_fwd(), for: .normal)
    }
    
    let marketingCheckButton = UIButton().then {
        $0.setImage(Icon.Check.generate(isOn: true, style: .line), for: .selected)
        $0.setImage(Icon.Check.generate(isOn: false, style: .line), for: .normal)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        $0.setTitle(R.string.localization.policy_marketing_label(), for: .normal)
        $0.titleLabel?.font = .regular(size: 14)
        $0.setTitleColor(R.color.gray5(), for: .normal)
    }
    
    let marketingButton = UIButton().then {
        $0.setImage(R.image.ic_fwd(), for: .normal)
    }
    
    let nextButton = UIButton().then {
        $0.setBackgroundColor(R.color.red() ?? .red, for: .normal)
        $0.setBackgroundColor(R.color.gray20() ?? .gray, for: .disabled)
        $0.isEnabled = false
        $0.layer.cornerRadius = 24
        $0.layer.masksToBounds = true
        $0.setTitle(R.string.localization.policy_next_button(), for: .normal)
        $0.titleLabel?.font = .bold(size: 16)
    }
    
    override func setup() {
        self.addSubViews([
            self.backgroundButton,
            self.containerView,
            self.allCheckButton,
            self.dividerView,
            self.policyCheckButton,
            self.policyButton,
            self.marketingCheckButton,
            self.marketingButton,
            self.nextButton
        ])
    }
    
    override func bindConstraints() {
        self.backgroundButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.containerView.snp.top)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-9)
            make.top.equalTo(self.allCheckButton).offset(-22)
        }
        
        self.nextButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(24)
            make.right.equalTo(self.containerView).offset(-24)
            make.height.equalTo(48)
            make.bottom.equalTo(self.containerView).offset(-24)
        }
        
        self.marketingCheckButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(28)
            make.height.equalTo(24)
            make.bottom.equalTo(self.nextButton.snp.top).offset(-32)
        }
        
        self.marketingButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.marketingCheckButton)
            make.right.equalTo(self.containerView).offset(-24)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        self.policyCheckButton.snp.makeConstraints { make in
            make.left.equalTo(self.marketingCheckButton)
            make.height.equalTo(24)
            make.bottom.equalTo(self.marketingCheckButton.snp.top).offset(-11)
        }
        
        self.policyButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.policyCheckButton)
            make.right.equalTo(self.containerView).offset(-24)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        self.dividerView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalTo(self.containerView).offset(24)
            make.right.equalTo(self.containerView).offset(-24)
            make.bottom.equalTo(self.policyCheckButton.snp.top).offset(-16)
        }
        
        self.allCheckButton.snp.makeConstraints { make in
            make.left.equalTo(self.marketingCheckButton)
            make.bottom.equalTo(self.dividerView.snp.top).offset(-20)
            make.height.equalTo(24)
        }
    }
}
