import UIKit

import Common
import DesignSystem
import Then

final class PollDetailCommentCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 100
    }

    private let userNameLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray80.color
    }

    private let badgeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }

    private let contentLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 14)
        $0.textColor = Colors.gray80.color
    }

    private let dateLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray40.color
    }

    private let reportButton = UIButton().then {
        $0.titleLabel?.font = Fonts.bold.font(size: 12)
        $0.setTitleColor(Colors.gray60.color, for: .normal)
        $0.contentEdgeInsets = .zero
    }

    private let lineView = UIView().then {
        $0.backgroundColor = Colors.gray10.color
    }

    override func setup() {
        super.setup()

        contentView.addSubViews([
            userNameLabel,
            dateLabel,
            reportButton,
            badgeStackView,
            contentLabel,
            lineView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        userNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().inset(20)
        }

        badgeStackView.snp.makeConstraints {
            $0.top.equalTo(userNameLabel.snp.bottom).offset(2)
            $0.leading.equalToSuperview().inset(20)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(badgeStackView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.trailing.equalTo(reportButton.snp.leading)
        }

        reportButton.snp.makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.trailing.equalToSuperview().inset(20)
        }

        lineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func bind() {
        userNameLabel.text = "관악구 광화문연가"
        dateLabel.text = "2023.04.30"
        reportButton.setTitle("신고", for: .normal)
        contentLabel.text = "슈붕을 좋아하면 델리만쥬를 먹지 왜 붕어빵을 먹음?"
    }
}
