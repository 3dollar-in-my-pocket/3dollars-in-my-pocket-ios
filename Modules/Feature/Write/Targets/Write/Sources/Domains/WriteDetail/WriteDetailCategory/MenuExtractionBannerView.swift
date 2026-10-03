import UIKit

import Common
import DesignSystem

final class MenuExtractionBannerView: BaseView {
    let registerButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.WriteDetailCategory.MenuExtractionBanner.button, attributes: AttributeContainer([
            .font: Fonts.bold.font(size: 12),
            .foregroundColor: Colors.systemWhite.color
        ]))
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        config.cornerStyle = .fixed
        config.background.cornerRadius = 10
        config.background.backgroundColor = Colors.mainPink.color
        let button = UIButton(configuration: config)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: Assets.iconCameraFlash.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.WriteDetailCategory.MenuExtractionBanner.title
        label.font = Fonts.semiBold.font(size: 14)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 2
        return label
    }()

    override func setup() {
        backgroundColor = Colors.gray0.color
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = Colors.gray10.color.cgColor
        iconContainerView.addSubview(iconImageView)
        addSubViews([
            iconContainerView,
            titleLabel,
            registerButton
        ])
    }

    override func bindConstraints() {
        iconContainerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(12)
            $0.size.equalTo(32)
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconContainerView.snp.trailing).offset(8)
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-12)
            $0.trailing.lessThanOrEqualTo(registerButton.snp.leading).offset(-8)
        }

        registerButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-12)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(34)
        }
    }
}
