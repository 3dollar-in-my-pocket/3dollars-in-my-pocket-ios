import UIKit

import Common
import DesignSystem
import Then

final class PollDetailContentCell: PollItemBaseCell {
    enum Layout {
        static let height: CGFloat = 238
    }
    
    override func setup() {
        super.setup()
        
        contentView.addSubViews([
            titleLabel,
            userInfoStackView,
            selectionStackView,
            countButton,
            deadlineLabel
        ])

        userInfoStackView.addArrangedSubview(userNameLabel)

        selectionStackView.addArrangedSubview(firstSelectionView)
        selectionStackView.addArrangedSubview(secondSelectionView)
    }

    override func bindConstraints() {
        super.bindConstraints()

        countButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(4)
            $0.leading.equalToSuperview().inset(20)
        }

        deadlineLabel.snp.makeConstraints {
            $0.centerY.equalTo(countButton)
            $0.trailing.equalToSuperview().inset(20)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(countButton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(20)
        }

        userInfoStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().inset(20)
        }

        selectionStackView.snp.makeConstraints {
            $0.top.equalTo(userInfoStackView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
