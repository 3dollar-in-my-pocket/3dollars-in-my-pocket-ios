import UIKit

import Common
import DesignSystem

final class CommunityStoreTabCell: BaseCollectionViewCell {

    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 450)
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.Pretendard.bold.font(size: 16)
        $0.textColor = Colors.systemBlack.color
        $0.text = "이번 주 동네 인기 가게"
    }

    private let descriptionLabel = UILabel().then {
        $0.font = Fonts.Pretendard.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
        $0.text = "아직 서울만 볼 수 있어요! 조금만 기다려 주세요 :)"
    }

    private let locationButton = UIButton().then {
        $0.titleLabel?.font = Fonts.Pretendard.semiBold.font(size: 14)
        $0.setTitle("관악구", for: .normal)
        $0.backgroundColor = Colors.gray10.color
        $0.layer.cornerRadius = 8
        $0.imageEdgeInsets.left = 2
        $0.semanticContentAttribute = .forceRightToLeft
        $0.contentEdgeInsets = .init(top: 6, left: 8, bottom: 6, right: 8)
        $0.setTitleColor(Colors.gray80.color, for: .normal)
        $0.setImage(Icons.arrowRight.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.gray60.color), for: .normal)
    }

    private let tabView = CommunityTabView(titles: ["리뷰가 많아요", "많이 왔다갔어요"])

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.contentInset = .init(top: 24, left: 0, bottom: 24, right: 0)
        $0.showsVerticalScrollIndicator = false
        $0.register([CommunityStoreItemCell.self])
        $0.dataSource = self
        $0.delegate = self
    }

    override func setup() {
        super.setup()

        backgroundColor = Colors.systemWhite.color

        contentView.addSubViews([
            titleLabel,
            descriptionLabel,
            locationButton,
            tabView,
            collectionView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.equalTo(titleLabel)
        }

        locationButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(38)
            $0.trailing.equalToSuperview().inset(20)
        }

        tabView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(tabView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CommunityStoreItemCell.Layout.size
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 9
        layout.minimumInteritemSpacing = 9

        return layout
    }
}

extension CommunityStoreTabCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CommunityStoreItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        cell.bind()
        return cell
    }
}

extension CommunityStoreTabCell: UICollectionViewDelegate {

}

// MARK: - CommunityStoreItemCell

final class CommunityStoreItemCell: BaseCollectionViewCell {

    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width - 40, height: 72)
    }

    private let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.backgroundColor = Colors.gray10.color
    }

    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.Pretendard.bold.font(size: 16)
        $0.textColor = Colors.gray100.color
    }

    private let tagStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
    }

    private let tagLabel = UILabel().then {
        $0.font = Fonts.Pretendard.medium.font(size: 12)
        $0.textColor = Colors.gray40.color
    }

    private let imageView = UIImageView().then {
        $0.backgroundColor = .clear
    }

    override func setup() {
        super.setup()

        contentView.addSubViews([
            containerView
        ])

        containerView.addSubViews([
            titleStackView,
            tagStackView,
            imageView
        ])

        titleStackView.addArrangedSubview(tagStackView)
        titleStackView.addArrangedSubview(titleLabel)

        tagStackView.addArrangedSubview(tagLabel)
    }

    override func bindConstraints() {
        super.bindConstraints()

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        imageView.snp.makeConstraints {
            $0.size.equalTo(48)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }

        titleStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
    }

    func bind() {
        imageView.image = Icons.faceSmile.image
        titleLabel.text = "강남역 0번 출구 앞 붕어빵"
        tagLabel.text = "#붕어빵"
    }
}
