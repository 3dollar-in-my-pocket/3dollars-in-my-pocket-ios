import UIKit
import Common
import DesignSystem
import Model

final class BossStoreMenuItemCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 44
    }
    
    private let nameLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = Colors.gray100.color
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
    }
    
    private let priceLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
    }
    
    private let imageView = UIImageView().then {
        $0.layer.cornerRadius = 21
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.gray10.color
    }
    
    override func setup() {
        super.setup()
        
        backgroundColor = .clear
        
        contentView.addSubViews([
            imageView,
            stackView
        ])
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(priceLabel)
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }
    }
    
    func bind(menu: BossStoreMenu) {
        imageView.setImage(urlString: menu.imageUrl)
        nameLabel.text = menu.name
        priceLabel.text = Strings.BossStoreDetail.Menu.priceFormat(menu.price.decimalFormat ?? "")
    }
}
