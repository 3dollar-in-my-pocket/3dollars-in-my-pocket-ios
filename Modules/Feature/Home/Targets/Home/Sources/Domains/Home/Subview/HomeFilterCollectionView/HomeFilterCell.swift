import UIKit

import Common
import Model

import Kingfisher

final class HomeFilterCell: BaseCollectionViewCell {
    enum Layout {
        static let iconSize = CGSize(width: 18, height: 18)
        static let leadingMargin: CGFloat = 8
        static let stackViewSpacing: CGFloat = 2
        static let trailingMargin: CGFloat = 10
        static func size(title: String?) -> CGSize {
            guard let title = title else { return .zero }
            let stringWidth = NSString(string: title).size().width
            let width = leadingMargin + iconSize.width + stackViewSpacing + stringWidth + trailingMargin
            return CGSize(width: width, height: 34)
        }
    }
    
    private let containerView = UIView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.category.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.gray70.color)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.medium.font(size: 12)
        titleLabel.textColor = Colors.gray70.color
        titleLabel.text = HomeStrings.homeCategoryFilterButton
        return titleLabel
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setSelected(false)
    }
    
    override func setup() {
        layer.borderColor = Colors.gray30.color.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
        layer.masksToBounds = true
        clipsToBounds = true
        backgroundColor = Colors.systemWhite.color
        
        stackView.addArrangedSubview(iconImage)
        iconImage.snp.makeConstraints {
            $0.size.equalTo(18)
        }
        stackView.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(18)
        }
        
        containerView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.top.equalToSuperview().offset(8)
            $0.height.equalTo(18)
        }
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(category: PlatformStoreCategory?) {
        if let category = category,
           let categoryUrl = URL(string: category.imageUrl) {
            KingfisherManager.shared.retrieveImage(with: categoryUrl) { [weak self] result in
                switch result {
                case .success(let imageResult):
                    let image = imageResult.image
                        .resizeImage(scaledTo: 16)
                        .withImageInset(insets: .init(top: 2, left: 2, bottom: 2, right: 2))
                    self?.iconImage.image = image
                case .failure(_):
                    self?.iconImage.image = nil
                }
            }
            titleLabel.text = category.name
            titleLabel.textColor = Colors.mainPink.color
            backgroundColor = Colors.gray100.color
        } else {
            iconImage.image = Icons.category.image
                .resizeImage(scaledTo: 16)
                .withImageInset(insets: .init(top: 2, left: 2, bottom: 2, right: 2))
                .withTintColor(Colors.gray70.color)
            titleLabel.text = HomeStrings.homeCategoryFilterButton
            titleLabel.textColor = Colors.gray70.color
            backgroundColor = Colors.systemWhite.color
        }
    }
    
    func bind(icon: UIImage?, title: String?, isSelected: Bool = false) {
        iconImage.image = icon
        titleLabel.text = title
        setSelected(isSelected)
    }
    
    private func setSelected(_ isSelected: Bool) {
        if isSelected {
            backgroundColor = Colors.pink100.color
            layer.borderColor = Colors.mainPink.color.cgColor
            titleLabel.textColor = Colors.mainPink.color
        } else {
            backgroundColor = Colors.systemWhite.color
            layer.borderColor = Colors.gray30.color.cgColor
            titleLabel.textColor = Colors.gray70.color
        }
    }
}
