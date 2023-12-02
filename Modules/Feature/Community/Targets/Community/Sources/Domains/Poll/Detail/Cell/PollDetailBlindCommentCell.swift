import UIKit

import Common
import DesignSystem
import Then

final class PollDetailBlindCommentCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 52
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 14)
        $0.textColor = Colors.gray50.color
        $0.text = "규정 위반으로 블라인드 처리되었습니다."
    }

    private let lineView = UIView().then {
        $0.backgroundColor = Colors.gray10.color
    }

    override func setup() {
        super.setup()
        backgroundColor = Colors.systemWhite.color
        contentView.addSubViews([
            titleLabel,
            lineView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        lineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}
