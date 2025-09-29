import UIKit

import Common

final class WriteDetailMenuEditCategoryCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: 120, height: 32)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.mainPink.color.cgColor
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = WriteAsset.icSettingFill.image
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray90.color
        label.textAlignment = .left
        label.text = Strings.WriteDetailMenu.editCategory
        return label
    }()
    
    override func setup() {
        contentView.addSubViews([
            containerView,
            imageView,
            titleLabel
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.size.equalTo(20)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().offset(-4)
        }
    }
}
