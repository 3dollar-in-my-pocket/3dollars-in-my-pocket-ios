import UIKit

import Common
import DesignSystem

final class CommunityPollListCell: BaseCollectionViewCell {

    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 426)
    }

    private let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.bold.font(size: 24)
        $0.textColor = DesignSystemAsset.Colors.gray100.color
        $0.numberOfLines = 2
        $0.text = "그만싸워 얘덜아...\n먹을걸로 왜그래..."
    }

    private let moreButton = UIButton().then {
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 18)
        $0.setTitle("맛짱 투표", for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.gray80.color, for: .normal)
        $0.setImage(DesignSystemAsset.Icons.fireSolid.image
            .resizeImage(scaledTo: 16)
            .withTintColor(DesignSystemAsset.Colors.mainRed.color), for: .normal)
    }

    private let arrowImageView = UIImageView().then {
        $0.image = DesignSystemAsset.Icons.arrowRight.image
            .resizeImage(scaledTo: 16)
            .withTintColor(DesignSystemAsset.Colors.gray80.color)
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.contentInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        $0.showsHorizontalScrollIndicator = false
        $0.register([CommunityPollItemCell.self])
        $0.dataSource = self
        $0.delegate = self
    }

    override func setup() {
        super.setup()

        contentView.addSubViews([
            titleLabel,
            moreButton,
            arrowImageView,
            collectionView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        moreButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(20)
        }

        arrowImageView.snp.makeConstraints {
            $0.centerY.equalTo(moreButton)
            $0.leading.equalTo(moreButton.snp.trailing).offset(2)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(moreButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CommunityPollItemCell.Layout.size
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16

        return layout
    }
}

extension CommunityPollListCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CommunityPollItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        cell.bind()
        return cell
    }
}

extension CommunityPollListCell: UICollectionViewDelegate {

}

// MARK: - CommunityPollItemCell

final class CommunityPollItemCell: BaseCollectionViewCell {

    enum Layout {
        static let size = CGSize(width: 280, height: 242)
    }

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.backgroundColor = DesignSystemAsset.Colors.systemWhite.color
    }

    private let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 20)
        $0.textColor = DesignSystemAsset.Colors.gray90.color
    }

    private let userInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
    }

    private let userNameLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray80.color
    }

    private let selectionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
    }

    private let firstSelectionView = CommunityPollSelectionView()

    private let secondSelectionView = CommunityPollSelectionView()

    private let commentButton = UIButton().then {
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.setTitleColor(DesignSystemAsset.Colors.gray50.color, for: .normal)
        $0.setImage(DesignSystemAsset.Icons.communityLine.image
            .resizeImage(scaledTo: 16)
            .withTintColor(DesignSystemAsset.Colors.gray50.color), for: .normal)
    }

    private let countButton = UIButton().then {
        $0.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.setTitleColor(DesignSystemAsset.Colors.gray50.color, for: .normal)
        $0.setImage(DesignSystemAsset.Icons.fireLine.image
            .resizeImage(scaledTo: 16)
            .withTintColor(DesignSystemAsset.Colors.gray50.color), for: .normal)
    }

    private let deadlineLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        $0.textColor = DesignSystemAsset.Colors.gray50.color
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
        $0.layer.borderColor = DesignSystemAsset.Colors.gray30.color.cgColor
        $0.layer.borderWidth = 1
    }

    let titleLabel = UILabel().then {
        $0.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        $0.textColor = DesignSystemAsset.Colors.gray100.color
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
