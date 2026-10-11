import UIKit

import Common
import DesignSystem
import Model

final class MenuCategoryView: BaseView {
    enum Layout {
        static let height: CGFloat = 70
    }

    let addMenuButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = Colors.gray70.color
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.image = Icons.plus.image
            .resizeImage(scaledTo: 18)
            .withRenderingMode(.alwaysTemplate)
        config.imagePadding = 4
        config.baseForegroundColor = Colors.gray10.color
        config.attributedTitle = AttributedString(Strings.WriteDetailMenu.addMenu, attributes: AttributeContainer([
            .font: Fonts.bold.font(size: 12),
            .foregroundColor: Colors.gray10.color
        ]))
        return UIButton(configuration: config)
    }()

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
        backgroundColor = Colors.systemWhite.color
        addSubViews([
            imageView,
            titleLabel,
            addMenuButton
        ])
    }

    override func bindConstraints() {
        addMenuButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(20)
            $0.height.equalTo(34)
        }

        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(24)
            $0.centerY.equalTo(addMenuButton)
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(imageView)
            $0.leading.equalTo(imageView.snp.trailing).offset(4)
            $0.trailing.lessThanOrEqualTo(addMenuButton.snp.leading).offset(-16)
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
