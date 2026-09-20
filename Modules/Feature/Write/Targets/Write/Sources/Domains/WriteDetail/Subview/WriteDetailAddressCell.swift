import UIKit

import Common
import DesignSystem

final class WriteDetailAddressCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 60)
    }
    
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = Colors.gray10.color
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        return containerView
    }()
    
    private let addressLabel: UILabel = {
        let addressLabel = UILabel()
        addressLabel.font = Fonts.regular.font(size: 14)
        addressLabel.textColor = Colors.gray50.color
        return addressLabel
    }()
    
    let editAddressButton: UIButton = {
        let editAddressButton = UIButton()
        editAddressButton.setTitleColor(Colors.mainPink.color, for: .normal)
        editAddressButton.titleLabel?.font = Fonts.semiBold.font(size: 14)
        editAddressButton.setTitle(Strings.writeDetailEditLocation, for: .normal)
        return editAddressButton
    }()
    
    override func setup() {
        backgroundColor = Colors.systemWhite.color
        contentView.addSubViews([
            containerView,
            addressLabel,
            editAddressButton
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        addressLabel.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(12)
            $0.right.equalTo(editAddressButton.snp.left).offset(-10)
            $0.centerY.equalTo(containerView)
        }
        
        editAddressButton.snp.makeConstraints {
            $0.centerY.equalTo(containerView)
            $0.right.equalTo(containerView).offset(-12)
        }
    }
    
    func bind(address: String?) {
        addressLabel.text = address
    }
}
