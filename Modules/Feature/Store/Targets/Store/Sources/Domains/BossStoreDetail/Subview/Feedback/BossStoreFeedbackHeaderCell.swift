import UIKit

import Common
import DesignSystem

final class BossStoreFeedbackHeaderCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 68
    }

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.semiBold.font(size: 20)
        titleLabel.textColor = Colors.gray100.color
        titleLabel.text = "이 가게에서 가장 좋았던 점은 무엇인가요?" // Strings.BossStoreFeedback.Content.title
        return titleLabel
    }()

    private let subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.font = Fonts.medium.font(size: 12)
        subtitleLabel.textColor = Colors.gray50.color
        subtitleLabel.text = Strings.BossStoreFeedback.Content.subtitle
        return subtitleLabel
    }()

    override func setup() {
        super.setup()

        contentView.addSubViews([
            titleLabel,
            subtitleLabel
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(14)
            $0.leading.trailing.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview()
        }
    }
}
