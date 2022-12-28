import UIKit

final class AddressConfirmPopupView: BaseView {
    let tapBackground = UITapGestureRecognizer()
    
    private let backgroundView = UIView()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 30
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .light(size: 24)
        $0.textColor = Color.black
        $0.attributedText = NSMutableAttributedString(
            string: "write_address_confirm_popup_title".localized,
            attributes: [.kern: -0.5]
        )
        $0.numberOfLines = 0
    }
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_close_24"), for: .normal)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "write_address_confirm_popup_description".localized
        $0.font = .semiBold(size: 14)
        $0.textColor = Color.gray50
    }
    
    private let addressContainerView = UIView().then {
        $0.backgroundColor = Color.gray0
        $0.layer.cornerRadius = 8
    }
    
    private let addressLabel = UILabel().then {
        $0.textColor = Color.gray100
        $0.font = .semiBold(size: 16)
        $0.textAlignment = .center
    }
    
    let okButton = UIButton().then {
        $0.layer.cornerRadius = 24
        $0.backgroundColor = Color.red
        $0.titleLabel?.font = .bold(size: 16)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("write_address_confirm_popup_ok".localized, for: .normal)
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.backgroundView.addGestureRecognizer(self.tapBackground)
        self.addSubViews([
            self.backgroundView,
            self.containerView,
            self.titleLabel,
            self.closeButton,
            self.descriptionLabel,
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
            make.top.equalTo(self.titleLabel).offset(-32)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }
        
        self.okButton.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(12)
            make.right.equalTo(self.containerView).offset(-12)
            make.height.equalTo(48)
            make.bottom.equalTo(self.containerView).offset(-32)
        }
        
        self.addressContainerView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(12)
            make.right.equalTo(self.containerView).offset(-12)
            make.bottom.equalTo(self.okButton.snp.top).offset(-16)
            make.height.equalTo(48)
        }
        
        self.addressLabel.snp.makeConstraints { make in
            make.left.equalTo(self.addressContainerView).offset(12)
            make.right.equalTo(self.addressContainerView).offset(-12)
            make.centerY.equalTo(self.addressContainerView)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(24)
            make.bottom.equalTo(self.addressContainerView.snp.top).offset(-24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(24)
            make.right.equalTo(self.closeButton.snp.left).offset(-12)
            make.bottom.equalTo(self.descriptionLabel.snp.top).offset(-12)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.top.equalTo(self.containerView).offset(32)
            make.right.equalTo(self.containerView).offset(-24)
            make.width.height.equalTo(24)
        }
    }
    
    func bind(address: String) {
        self.addressLabel.text = address
    }
}
