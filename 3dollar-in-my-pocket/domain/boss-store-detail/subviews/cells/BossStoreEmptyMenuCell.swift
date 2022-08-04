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
        $0.text = "아직 등록된 정보가 없어요."
        $0.textColor = R.color.gray30()
        $0.font = .regular(size: 14)
    }
    
    private let emptyImage = UIImageView().then {
        $0.image = UIImage(named: "img_boss_empty_menu")
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
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.centerY.equalTo(self.titleLabel)
        }
        
        self.emptyImage.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.right.equalTo(self.containerView).offset(-16)
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
    }
}
