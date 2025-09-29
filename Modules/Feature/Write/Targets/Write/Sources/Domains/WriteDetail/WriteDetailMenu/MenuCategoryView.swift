import UIKit

import Common
import Model

final class MenuCategoryView: BaseView {
    enum Layout {
        static let height: CGFloat = 44
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray95.color
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
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(24)
            $0.top.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(imageView)
            $0.leading.equalTo(imageView.snp.trailing).offset(4)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }
    
    func bind(category: StoreFoodCategoryResponse) {
        imageView.setImage(urlString: category.imageUrl)
        titleLabel.text = category.name
    }
}
