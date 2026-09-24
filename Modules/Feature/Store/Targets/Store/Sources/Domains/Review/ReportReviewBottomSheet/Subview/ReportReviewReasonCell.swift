import UIKit

import Common
import DesignSystem

final class ReportReviewReasonCell: BaseCollectionViewCell {

    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width - 40, height: 44)
    }

    private let containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.layer.borderColor = Colors.gray40.color.cgColor
        containerView.layer.borderWidth = 1
        return containerView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.regular.font(size: 14)
        titleLabel.textColor = Colors.gray60.color
        return titleLabel
    }()

    private let checkImageView: UIImageView = {
        let checkImageView = UIImageView()
        checkImageView.image = Icons.check.image
            .resizeImage(scaledTo: 20)
            .withTintColor(Colors.mainRed.color)
        checkImageView.isHidden = true
        return checkImageView
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = Colors.gray100.color
                containerView.layer.borderColor = Colors.mainRed.color.cgColor
                checkImageView.isHidden = false
            } else {
                titleLabel.textColor = Colors.gray60.color
                containerView.layer.borderColor = Colors.gray40.color.cgColor
                checkImageView.isHidden = true
            }
        }
    }

    override func setup() {
        super.setup()

        contentView.addSubViews([
            containerView
        ])

        containerView.addSubViews([
            titleLabel,
            checkImageView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }

        checkImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
    }

    func bind(title: String) {
        titleLabel.text = title
    }
}
