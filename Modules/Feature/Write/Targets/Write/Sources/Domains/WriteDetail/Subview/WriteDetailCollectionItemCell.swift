import UIKit

import Common
import DesignSystem
import Model

final class WriteDetailCollectionItemCell: BaseCollectionViewCell {
    enum Layout {
        static let width = (UIScreen.main.bounds.width - 40 - 24 - 40)/5
        static let size = CGSize(width: width, height: width - 14 + 22)
    }
    
    let categoryButton: UIButton = {
        let categoryButton = UIButton()
        categoryButton.layer.cornerRadius = (Layout.width - 14) / 2
        categoryButton.layer.masksToBounds = true
        categoryButton.layer.borderColor = Colors.mainPink.color.cgColor
        categoryButton.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        return categoryButton
    }()
    
    let closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.backgroundColor = Colors.mainRed.color
        closeButton.layer.cornerRadius = 8
        closeButton.setImage(Icons.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = Colors.gray0.color
        closeButton.contentEdgeInsets = .init(top: 3, left: 3, bottom: 3, right: 3)
        return closeButton
    }()
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.medium.font(size: 12)
        titleLabel.textColor = Colors.gray80.color
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        closeButton.isHidden = false
        categoryButton.backgroundColor = .clear
        categoryButton.layer.borderWidth = 0
    }
    
    override func setup() {
        contentView.addSubViews([
            categoryButton,
            closeButton,
            titleLabel
        ])
    }
    
    override func bindConstraints() {
        categoryButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(Layout.width - 14)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(categoryButton)
            $0.trailing.equalTo(categoryButton)
            $0.width.height.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(categoryButton.snp.bottom).offset(4)
        }
    }
    
    func bind(category: Model.PlatformStoreCategory?) {
        if let category = category {
            categoryButton.layer.borderWidth = 1
            categoryButton.setImage(urlString: category.imageUrl, state: .normal)
            titleLabel.text = category.name
        } else {
            setAddButton()
        }
    }
    
    private func setAddButton() {
        closeButton.isHidden = true
        categoryButton.backgroundColor = Colors.gray100.color
        categoryButton.setImage(Icons.plus.image.withTintColor(Colors.mainPink.color), for: .normal)
        categoryButton.layer.borderWidth = 0
        titleLabel.text = "추가하기"
    }
}
