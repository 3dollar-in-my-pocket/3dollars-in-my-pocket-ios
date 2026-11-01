import UIKit

import Common

final class FeedEmptyCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 280
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView(image: Assets.imgEmptyList.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.FeedList.Empty.title
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray70.color
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.FeedList.Empty.description
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray70.color
        return label
    }()

    override func setup() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.setCustomSpacing(8, after: imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(4, after: titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
    }

    override func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
}
