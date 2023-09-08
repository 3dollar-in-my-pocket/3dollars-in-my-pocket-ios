import UIKit

import Common
import DesignSystem


final class PollDetailContentCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = 238
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.Pretendard.bold.font(size: 24)
        $0.textColor = Colors.gray90.color
    }

    private let userInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }

    private let userNameLabel = UILabel().then {
        $0.font = Fonts.Pretendard.medium.font(size: 12)
        $0.textColor = Colors.gray80.color
    }

    private let selectionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
    }

    private let firstSelectionView = CommunityPollSelectionView()

    private let secondSelectionView = CommunityPollSelectionView()

    private let countButton = UIButton().then {
        $0.titleLabel?.font = Fonts.Pretendard.semiBold.font(size: 14)
        $0.setTitleColor(Colors.gray100.color, for: .normal)
        $0.setImage(Icons.fireSolid.image
            .resizeImage(scaledTo: 20)
            .withTintColor(Colors.mainRed.color), for: .normal)
    }

    private let deadlineLabel = UILabel().then {
        $0.font = Fonts.Pretendard.medium.font(size: 12)
        $0.textColor = Colors.gray50.color
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

    func bind() {
        titleLabel.text = "내가 정상 님들이 비정상"
        userNameLabel.text = "관악구 광화문연가"
        countButton.setTitle("400명 투표", for: .normal)
        deadlineLabel.text = "오늘 마감"

        firstSelectionView.titleLabel.text = "슈붕 비정상 팥붕 정상"
        secondSelectionView.titleLabel.text = "먼솔 슈붕임"
    }
}
