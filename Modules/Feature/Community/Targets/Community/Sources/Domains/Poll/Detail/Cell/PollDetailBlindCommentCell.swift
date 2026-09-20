import UIKit

import Common
import DesignSystem

final class PollDetailBlindCommentCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 52
    }

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.regular.font(size: 14)
        titleLabel.textColor = Colors.gray50.color
        titleLabel.text = "규정 위반으로 블라인드 처리되었습니다."
        return titleLabel
    }()

    private let lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = Colors.gray10.color
        return lineView
    }()

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
