import UIKit

import Common
import DesignSystem
import Model

final class PollItemCell: PollItemBaseCell {

    enum Layout {
        static let size = CGSize(width: 280, height: 242)
    }

    override func setup() {
        super.setup()

        contentView.addSubViews([
            containerView
        ])

        containerView.addSubViews([
            titleLabel,
            userInfoStackView,
            selectionStackView,
            commentButton,
            countButton,
            deadlineLabel
        ])

        userInfoStackView.addArrangedSubview(userNameLabel)
        userInfoStackView.addArrangedSubview(medalView)

        selectionStackView.addArrangedSubview(firstSelectionView)
        selectionStackView.addArrangedSubview(secondSelectionView)
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(8)
        }

        userInfoStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalTo(titleLabel)
        }

        selectionStackView.snp.makeConstraints {
            $0.top.equalTo(userInfoStackView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(12)
        }

        commentButton.snp.makeConstraints {
            $0.top.equalTo(selectionStackView.snp.bottom).offset(16)
            $0.leading.bottom.equalToSuperview().inset(16)
        }

        countButton.snp.makeConstraints {
            $0.top.bottom.equalTo(commentButton)
            $0.leading.equalTo(commentButton.snp.trailing).offset(12)
        }

        deadlineLabel.snp.makeConstraints {
            $0.top.bottom.equalTo(commentButton)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}
