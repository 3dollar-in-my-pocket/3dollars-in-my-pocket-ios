import UIKit

final class AddressConfirmPopupView: BaseView {
    let tapBackground = UITapGestureRecognizer()
    
    private let backgroundView = UIView()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 20)
        $0.textColor = R.color.black()
        $0.attributedText = NSMutableAttributedString(
            string: R.string.localization.write_address_confirm_popup_title(),
            attributes: [.kern: -0.5]
        )
        $0.numberOfLines = 0
    }
    
    private let addressContainerView = UIView().then {
        $0.backgroundColor = R.color.gray0()
        $0.layer.cornerRadius = 8
    }
    
    private let addressLabel = UILabel().then {
        $0.textColor = R.color.gray100()
        $0.font = .semiBold(size: 16)
        $0.textAlignment = .center
    }
    
    let okButton = UIButton().then {
        $0.layer.cornerRadius = 24
        $0.backgroundColor = R.color.red()
        $0.titleLabel?.font = .bold(size: 16)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle(R.string.localization.write_address_confirm_popup_ok(), for: .normal)
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.backgroundView.addGestureRecognizer(self.tapBackground)
        self.addSubViews([
            self.backgroundView,
            self.containerView,
            self.titleLabel,
            self.addressContainerView,
            self.addressLabel,
            self.okButton
        ])
    }
    
    override func bindConstraints() {
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.titleLabel).offset(-40)
            make.bottom.equalTo(self.okButton).offset(48)
        }
        
        self.addressContainerView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(12)
            make.right.equalTo(self.containerView).offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(48)
        }
        
        self.addressLabel.snp.makeConstraints { make in
            make.left.equalTo(self.addressContainerView).offset(12)
            make.right.equalTo(self.addressContainerView).offset(-12)
            make.centerY.equalTo(self.addressContainerView)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(12)
            make.right.equalTo(self.containerView).offset(-12)
            make.bottom.equalTo(self.addressContainerView.snp.top).offset(-16)
        }
        
        self.okButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(12)
            make.right.equalTo(self.containerView).offset(-12)
            make.top.equalTo(self.addressContainerView.snp.bottom).offset(28)
            make.height.equalTo(48)
        }
    }
    
    func bind(address: String) {
        self.addressLabel.text = address
    }
}
