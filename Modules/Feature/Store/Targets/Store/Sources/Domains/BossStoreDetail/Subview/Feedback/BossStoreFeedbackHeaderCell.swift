import UIKit

import Common
import DesignSystem
import Then

final class BossStoreFeedbackHeaderCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 108
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 24)
        $0.textColor = Colors.gray100.color
        $0.textAlignment = .center
        $0.text = Strings.BossStoreFeedback.Content.title
    }

    private let subtitleLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.mainPink.color
        $0.textAlignment = .center
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
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
