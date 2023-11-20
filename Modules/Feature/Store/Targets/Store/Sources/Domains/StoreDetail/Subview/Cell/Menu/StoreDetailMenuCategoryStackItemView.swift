import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailMenuCategoryStackItemView: BaseView {
    enum Layout {
        static let height: CGFloat = 28
    }
    
    private let imageView = UIImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.gray100.color
        label.font = Fonts.semiBold.font(size: 14)
        
        return label
    }()
    
    override func setup() {
        addSubViews([
            imageView,
            titleLabel
        ])
    }
    
    override func bindConstraints() {
        imageView.snp.makeConstraints {
            $0.size.equalTo(28)
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.left.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(imageView.snp.right).offset(8)
            $0.right.lessThanOrEqualToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }
    
    func bind(_ category: PlatformStoreCategory) {
        imageView.setImage(urlString: category.imageUrl)
        titleLabel.text = category.name
    }
}

