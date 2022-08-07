import UIKit

import Base

final class BossStoreMenuCell: BaseCollectionViewCell {
    static let registerId = "\(BossStoreMenuCell.self)"
    static let height: CGFloat = 86
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    
    private let stackView = UIStackView().then {
        $0.spacing = 4
        $0.axis = .vertical
        $0.alignment = .leading
    }
    
    private let nameLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = R.color.gray95()
    }
    
    private let priceLabel = UILabel().then {
        $0.font = .medium(size: 14)
        $0.textColor = R.color.gray95()
    }
    
    private let photoView = UIImageView().then {
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.stackView.addArrangedSubview(self.nameLabel)
        self.stackView.addArrangedSubview(self.priceLabel)
        self.addSubViews([
            self.containerView,
            self.stackView,
            self.photoView
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        self.stackView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(16)
            make.centerY.equalTo(self.containerView)
            make.right.equalTo(self.photoView.snp.left).offset(-40)
        }
        
        self.photoView.snp.makeConstraints { make in
            make.right.equalTo(self.containerView).offset(-16)
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.centerY.equalTo(self.containerView)
        }
    }
    
    func bind(menu: BossStoreMenu) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let price = numberFormatter.string(for: menu.price)

        
        self.nameLabel.text = menu.name
        self.priceLabel.text = price
        self.photoView.setImage(urlString: menu.imageUrl)
    }
}
