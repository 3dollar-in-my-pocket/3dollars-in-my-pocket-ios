import UIKit

import Common
import DesignSystem
import SnapKit

final class BossStoreVerifiedBannerCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 41
        static func size(width: CGFloat) -> CGSize {
            return CGSize(width: width, height: height)
        }
    }

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray90.color
        view.layer.cornerRadius = 12
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Icons.checkVerified.image
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    override func setup() {
        setupUI()
        setupAttributedText()
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubViews([
            iconImageView,
            titleLabel
        ])
    }

    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(21)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(5)
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }
    }

    private func setupAttributedText() {
        let fullText = "가슴속 3천원이 직접 확인한 공식 인증가게입니다!"
        let highlightText = "공식 인증"

        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: Fonts.regular.font(size: 14),
                .foregroundColor: Colors.systemWhite.color
            ]
        )

        if let range = fullText.range(of: highlightText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes([
                .font: Fonts.semiBold.font(size: 14),
                .foregroundColor: Colors.mainPink.color
            ], range: nsRange)
        }

        titleLabel.attributedText = attributedString
    }
}
