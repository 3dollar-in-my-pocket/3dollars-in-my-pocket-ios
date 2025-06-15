import UIKit
import Common
import DesignSystem
import Model

final class StoreDetailImageMenuItemCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 44
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray60.color
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 21
        imageView.clipsToBounds = true
        imageView.backgroundColor = Colors.gray10.color
        return imageView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    override func setup() {
        super.setup()
        
        backgroundColor = .clear
        
        contentView.addSubViews([
            imageView,
            stackView
        ])
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
    
    func bind(menu: StoreImageMenusSectionResponse.StoreImageMenuSectionResponse) {
        imageView.setImage(urlString: menu.image.url)
        nameLabel.setSDText(menu.title)
        stackView.addArrangedSubview(nameLabel)
        
        if let subTitle = menu.subTitle {
            priceLabel.setSDText(subTitle)
            stackView.addArrangedSubview(priceLabel)
        }
    }
}
