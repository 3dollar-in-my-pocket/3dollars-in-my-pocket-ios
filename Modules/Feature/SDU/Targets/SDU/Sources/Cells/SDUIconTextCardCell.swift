import UIKit

import Common
import DesignSystem
import Kingfisher
import Model
import SnapKit

public final class SDUIconTextCardCell: BaseCollectionViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let subTitleLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 3, bottomInset: 3, leftInset: 8, rightInset: 8)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.font = Fonts.medium.font(size: 12)
        label.numberOfLines = 0
        return label
    }()

    private let metadataLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = Colors.gray50.color
        label.font = Fonts.medium.font(size: 12)
        label.textAlignment = .right
        return label
    }()
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        subTitleLabel.snp.removeConstraints()
    }

    public override func setup() {
        super.setup()

        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subTitleLabel)
        containerView.addSubview(metadataLabel)
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

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
            $0.height.equalTo(24)
        }

        metadataLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    public func bind(_ viewModel: SDUIconTextCardCellViewModel) {
        let data = viewModel.output.data

        if let url = URL(string: data.image.url) {
            iconImageView.kf.setImage(with: url)
        }

        iconImageView.snp.updateConstraints {
            $0.width.equalTo(data.image.style.width)
            $0.height.equalTo(data.image.style.height)
        }

        titleLabel.setSDText(data.title)

        if let subTitle = data.subTitle {
            subTitleLabel.isHidden = false
            subTitleLabel.setSDChip(subTitle)
            
            if subTitleLabel.backgroundColor.isNotNil {
                subTitleLabel.setPadding(top: 3, bottom: 3, left: 8, right: 8)
                subTitleLabel.snp.makeConstraints {
                    $0.leading.equalTo(titleLabel)
                    $0.trailing.lessThanOrEqualTo(metadataLabel.snp.leading).offset(-4)
                    $0.top.equalTo(titleLabel.snp.bottom).offset(4)
                    $0.bottom.equalToSuperview().offset(-16)
                    $0.height.equalTo(24)
                }
            } else {
                subTitleLabel.setLineHeight(lineHeight:  20)
                subTitleLabel.setPadding(top: 0, bottom: 0, left: 0, right: 0)
                subTitleLabel.snp.makeConstraints {
                    $0.leading.equalTo(titleLabel)
                    $0.trailing.lessThanOrEqualTo(metadataLabel.snp.leading).offset(-4)
                    $0.top.equalTo(titleLabel.snp.bottom).offset(4)
                    $0.bottom.equalToSuperview().offset(-16)
                }
            }
        } else {
            subTitleLabel.isHidden = true
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
