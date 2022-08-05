import UIKit

import Base

final class BossStoreEmptyMenuCell: BaseCollectionViewCell {
    static let registerId = "\(BossStoreEmptyMenuCell.self)"
    static let height: CGFloat = 52
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.backgroundColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.text = R.string.localization.boss_store_empty_menu()
        $0.textColor = R.color.gray30()
        $0.font = .regular(size: 14)
    }
    
    private let emptyImage = UIImageView().then {
        $0.image = R.image.img_boss_empty_menu()
    }
    
    override func setup() {
        self.addSubViews([
            self.containerView,
            self.titleLabel,
            self.emptyImage
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(52)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.centerY.equalTo(self.containerView)
        }
        
        self.emptyImage.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.right.equalTo(self.containerView).offset(-16)
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
    }
}
