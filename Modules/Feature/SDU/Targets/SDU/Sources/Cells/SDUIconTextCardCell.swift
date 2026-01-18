import UIKit

import Common
import DesignSystem
import Kingfisher
import Model
import SnapKit

public final class SDUIconTextCardCell: BaseCollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private let subTitleChipView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        return view
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    public override func setup() {
        super.setup()

        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(contentStackView)
        containerView.addSubview(metadataLabel)

        subTitleChipView.addSubview(subTitleLabel)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subTitleChipView)
    }

    public override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
            $0.width.height.equalTo(36)
        }

        contentStackView.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(metadataLabel.snp.leading).offset(-8)
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }

        subTitleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }

        metadataLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(titleLabel)
        }
    }

    public func bind(_ data: IconTextCardData) {
        if let url = URL(string: data.image.url) {
            iconImageView.kf.setImage(with: url)
        }

        iconImageView.snp.updateConstraints {
            $0.width.height.equalTo(data.image.style.width)
        }

        titleLabel.setSDText(data.title)

        if let subTitle = data.subTitle {
            subTitleChipView.isHidden = false
            subTitleLabel.setSDText(subTitle.text)

            if let backgroundColorHex = subTitle.style?.backgroundColor,
               let backgroundColor = UIColor(hex: backgroundColorHex) {
                subTitleChipView.backgroundColor = backgroundColor
            }
        } else {
            subTitleChipView.isHidden = true
        }

        if let metadata = data.metadata {
            metadataLabel.isHidden = false
            metadataLabel.setSDText(metadata)
        } else {
            metadataLabel.isHidden = true
        }

        containerView.setSDSurfaceStyle(data.style)
    }
}
