import UIKit

import Common
import DesignSystem

final class PollItemCell: BaseCollectionViewCell {

    enum Layout {
        static let size = CGSize(width: 280, height: 242)
    }

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.systemWhite.color
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 20)
        $0.textColor = Colors.gray90.color
    }

    private let userInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }

    private let userNameLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray80.color
    }

    private let selectionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
    }

    private let firstSelectionView = CommunityPollSelectionView()

    private let secondSelectionView = CommunityPollSelectionView()

    private let commentButton = UIButton().then {
        $0.titleLabel?.font = Fonts.medium.font(size: 12)
        $0.setTitleColor(Colors.gray50.color, for: .normal)
        $0.setImage(Icons.communityLine.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.gray50.color), for: .normal)
    }

    private let countButton = UIButton().then {
        $0.titleLabel?.font = Fonts.medium.font(size: 12)
        $0.setTitleColor(Colors.gray50.color, for: .normal)
        $0.setImage(Icons.fireLine.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.gray50.color), for: .normal)
    }

    private let deadlineLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray50.color
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
            $0.centerX.equalToSuperview()
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

    func bind() {
        titleLabel.text = "내가 정상 님들이 비정상"
        userNameLabel.text = "관악구 광화문연가"
        commentButton.setTitle("23", for: .normal)
        countButton.setTitle("400명 투표", for: .normal)
        deadlineLabel.text = "오늘 마감"

        firstSelectionView.titleLabel.text = "슈붕 비정상 팥붕 정상"
        secondSelectionView.titleLabel.text = "먼솔 슈붕임"
    }
}

// MARK: - CommunityPollSelectionView

final class CommunityPollSelectionView: BaseView {

    enum Layout {
        static let height: CGFloat = 44
    }

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.borderColor = Colors.gray30.color.cgColor
        $0.layer.borderWidth = 1
    }

    let titleLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 16)
        $0.textColor = Colors.gray100.color
    }

    override func setup() {
        super.setup()

        addSubViews([
            containerView,
        ])

        containerView.addSubViews([
            titleLabel
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
