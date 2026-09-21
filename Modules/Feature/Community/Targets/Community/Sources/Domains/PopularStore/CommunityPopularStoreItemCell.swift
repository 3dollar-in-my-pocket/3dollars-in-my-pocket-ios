import UIKit

import Common
import DesignSystem
import Model

final class CommunityPopularStoreItemCell: BaseCollectionViewCell {

    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 80)
    }

    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        containerView.backgroundColor = Colors.gray10.color
        return containerView
    }()

    private let titleStackView: UIStackView = {
        let titleStackView = UIStackView()
        titleStackView.axis = .vertical
        titleStackView.spacing = 4
        return titleStackView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.bold.font(size: 16)
        titleLabel.textColor = Colors.gray100.color
        return titleLabel
    }()

    private let tagStackView: UIStackView = {
        let tagStackView = UIStackView()
        tagStackView.axis = .horizontal
        tagStackView.spacing = 8
        return tagStackView
    }()

    private let tagLabel: UILabel = {
        let tagLabel = UILabel()
        tagLabel.font = Fonts.medium.font(size: 12)
        tagLabel.textColor = Colors.gray40.color
        return tagLabel
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        return imageView
    }()

    override func setup() {
        super.setup()

        backgroundColor = Colors.systemWhite.color
        
        contentView.addSubViews([
            containerView
        ])

        containerView.addSubViews([
            titleStackView,
            tagStackView,
            imageView
        ])

        titleStackView.addArrangedSubview(tagStackView)
        titleStackView.addArrangedSubview(titleLabel)

        tagStackView.addArrangedSubview(tagLabel)
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        imageView.snp.makeConstraints {
            $0.size.equalTo(48)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }

        titleStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
    }

    func bind(item: PlatformStore) {
        imageView.setImage(urlString: item.categories.first?.imageUrl)
        titleLabel.text = item.name
        tagLabel.text = item.categoriesString
    }
}
