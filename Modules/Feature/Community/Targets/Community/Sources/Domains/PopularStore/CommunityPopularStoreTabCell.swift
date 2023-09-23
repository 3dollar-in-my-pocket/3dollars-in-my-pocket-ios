import UIKit

import Common
import DesignSystem
import Then

final class CommunityPopularStoreTabCell: BaseCollectionViewCell {

    enum Layout {
        static func size(viewModel: CommunityPopularStoreTabCellViewModel) -> CGSize {
            let titleHeight: CGFloat = 88
            let tabHeight: CGFloat = CommunityTabView.Layout.height
            let itemCount = CGFloat(viewModel.output.storeList.count)
            let total: CGFloat = CommunityPopularStoreItemCell.Layout.size.height * itemCount + (itemSpacing * itemCount - 1) + 48.0
            return CGSize(
                width: UIScreen.main.bounds.width,
                height: titleHeight + tabHeight + total
            )
        }

        static let itemSpacing: CGFloat = 9
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.systemBlack.color
        $0.text = "이번 주 동네 인기 가게"
    }

    private let descriptionLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
        $0.text = "아직 서울만 볼 수 있어요! 조금만 기다려 주세요 :)"
    }

    let districtButton = UIButton().then {
        $0.titleLabel?.font = Fonts.semiBold.font(size: 14)
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
        $0.register([CommunityPopularStoreItemCell.self])
        $0.dataSource = self
        $0.delegate = self
        $0.isScrollEnabled = false
    }

    private var viewModel: CommunityPopularStoreTabCellViewModel?

    override func setup() {
        super.setup()

        backgroundColor = Colors.systemWhite.color

        contentView.addSubViews([
            titleLabel,
            descriptionLabel,
            districtButton,
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

        districtButton.snp.makeConstraints {
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

    func bind(viewModel: CommunityPopularStoreTabCellViewModel) {
        self.viewModel = viewModel

        districtButton.setTitle(viewModel.output.district, for: .normal)
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CommunityPopularStoreItemCell.Layout.size
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Layout.itemSpacing
        layout.minimumInteritemSpacing = Layout.itemSpacing

        return layout
    }
}

extension CommunityPopularStoreTabCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.output.storeList.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = viewModel?.output.storeList[safe: indexPath.item] else { return UICollectionViewCell() }

        let cell: CommunityPopularStoreItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        cell.bind(item: item)
        return cell
    }
}

extension CommunityPopularStoreTabCell: UICollectionViewDelegate {

}

