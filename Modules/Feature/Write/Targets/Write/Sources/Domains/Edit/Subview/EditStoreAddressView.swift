import UIKit
import SnapKit

import DesignSystem
import Common

final class EditStoreAddressView: BaseView {
    let tapGesture = UITapGestureRecognizer()
    
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = WriteAsset.iconMap.image.resizeImage(scaledTo: 24)
            .withImageInset(insets: .init(top: 4, left: 4, bottom: 4, right: 4))
        imageView.backgroundColor = Colors.gray10.color
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "가게 위치"
        label.textColor = Colors.gray100.color
        label.font = Fonts.semiBold.font(size: 14)
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "서울특별시 강남구 독립문로 14길"
        label.textColor = Colors.gray60.color
        label.font = Fonts.medium.font(size: 12)
        label.lineBreakMode = .byTruncatingHead
        label.numberOfLines = 1
        return label
    }()
    
    override func setup() {
        super.setup()
        
        addGestureRecognizer(tapGesture)
        backgroundColor = Colors.systemWhite.color
        layer.cornerRadius = 16
        layer.shadowColor = Colors.systemBlack.color.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(addressLabel)
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        iconView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(12)
            $0.size.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(8)
            $0.top.equalTo(iconView)
        }
        
        addressLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(66)
        }
    }
    
    func bind(address: String?) {
        addressLabel.text = address
    }
}
