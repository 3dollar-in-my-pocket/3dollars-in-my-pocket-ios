import UIKit

import DesignSystem

final class AddressConfirmPopupView: BaseView {
    let backgroundView = UIView()
    
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.systemWhite.color
        $0.layer.cornerRadius = 30
        $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.Pretendard.semiBold.font(size: 20)
        $0.textColor = Colors.gray100.color
        $0.attributedText = NSMutableAttributedString(
            string: Strings.writeAddressConfirmPopupTitle,
            attributes: [.kern: -1]
        )
        $0.numberOfLines = 2
    }
    
    let closeButton = UIButton().then {
        $0.setImage(Icons.close.image, for: .normal)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = Fonts.Pretendard.medium.font(size: 12)
        $0.textColor = Colors.gray50.color
        
        let text = Strings.writeAddressConfirmPopupDescription
        let attributedText = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "중복된 가게 제보")
        
        attributedText.addAttribute(.foregroundColor, value: Colors.gray80.color, range: range)
        $0.attributedText = attributedText
    }
    
    private let addressContainerView = UIView().then {
        $0.backgroundColor = Colors.gray10.color
        $0.layer.cornerRadius = 12
    }
    
    private let addressLabel = UILabel().then {
        $0.textColor = Colors.gray70.color
        $0.font = Fonts.Pretendard.bold.font(size: 16)
        $0.textAlignment = .center
    }
    
    let okButton = UIButton().then {
        $0.layer.cornerRadius = 12
        $0.backgroundColor = Colors.mainPink.color
        $0.titleLabel?.font = Fonts.Pretendard.semiBold.font(size: 14)
        $0.setTitleColor(Colors.systemWhite.color, for: .normal)
        $0.setTitle(Strings.writeAddressConfirmPopupOk, for: .normal)
    }
    
    override func setup() {
        backgroundColor = .clear
        addSubViews([
            backgroundView,
            containerView,
            titleLabel,
            closeButton,
            descriptionLabel,
            addressContainerView,
            addressLabel,
            okButton
        ])
    }
    
    override func bindConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(titleLabel).offset(-26)
            make.bottom.equalToSuperview()
        }
        
        okButton.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(20)
            make.right.equalTo(containerView).offset(-20)
            make.height.equalTo(48)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-12)
        }
        
        addressContainerView.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(20)
            make.right.equalTo(containerView).offset(-20)
            make.bottom.equalTo(okButton.snp.top).offset(-21)
            make.height.equalTo(48)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.left.equalTo(addressContainerView).offset(12)
            make.right.equalTo(addressContainerView).offset(-12)
            make.centerY.equalTo(addressContainerView)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(20)
            make.bottom.equalTo(addressContainerView.snp.top).offset(-20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(containerView).offset(20)
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-8)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(26)
            make.right.equalTo(containerView).offset(-20)
            make.width.height.equalTo(24)
        }
    }
    
    func bind(address: String) {
        addressLabel.text = address
    }
}
