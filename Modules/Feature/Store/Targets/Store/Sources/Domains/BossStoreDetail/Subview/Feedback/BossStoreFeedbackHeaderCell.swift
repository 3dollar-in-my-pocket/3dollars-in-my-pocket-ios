import UIKit

import Common
import DesignSystem
import Then

final class BossStoreFeedbackHeaderCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 68
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 20)
        $0.textColor = Colors.gray100.color
        $0.text = "이 가게에서 가장 좋았던 점은 무엇인가요?" // Strings.BossStoreFeedback.Content.title
    }

    private let subtitleLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray50.color
        $0.text = Strings.BossStoreFeedback.Content.subtitle
    }

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
