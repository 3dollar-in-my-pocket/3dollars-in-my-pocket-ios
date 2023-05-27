import UIKit

import DesignSystem

final class AddressConfirmPopupView: BaseView {
    let backgroundView = UIView()
    
    private let containerView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        $0.layer.cornerRadius = 30
    }
    
    private let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 20)
        $0.textColor = DesignSystemAsset.Colors.gray100.color
        $0.attributedText = NSMutableAttributedString(
            string: "write_address_confirm_popup_title".localized,
            attributes: [.kern: -1]
        )
        $0.numberOfLines = 2
    }
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_close_24"), for: .normal)
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray50.color
        
        let text = "write_address_confirm_popup_description".localized
        let attributedText = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: "중복된 가게 제보")
        
        attributedText.addAttribute(.foregroundColor, value: DesignSystemAsset.Colors.gray80.color, range: range)
        $0.attributedText = attributedText
    }
    
    private let addressContainerView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray10.color
        $0.layer.cornerRadius = 12
    }
    
    private let addressLabel = UILabel().then {
        $0.textColor = DesignSystemAsset.Colors.gray70.color
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        $0.textAlignment = .center
    }
    
    let okButton = UIButton().then {
        $0.layer.cornerRadius = 12
        $0.backgroundColor = DesignSystemAsset.Colors.mainPink.color
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 14)
        $0.setTitleColor(DesignSystemAsset.Colors.systemWhite.color, for: .normal)
        $0.setTitle("write_address_confirm_popup_ok".localized, for: .normal)
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
