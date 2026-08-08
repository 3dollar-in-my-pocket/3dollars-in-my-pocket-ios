import UIKit

import Common
import DesignSystem
import Model
import SnapKit

/// v1 캐러셀의 `StoreBridgeCarouselItemCell`을 그대로 재사용하는 v2 추천 가게 섹션.
final class StoreRelatedStoresV2Cell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.register([StoreBridgeCarouselItemCell.self])
        view.dataSource = self
        view.delegate = self
        return view
    }()
    private var cards: [StoreImagePreviewCard] = []

    override func prepareForReuse() {
        super.prepareForReuse()
        onAction = nil
        cards = []
    }

    override func setup() {
        contentView.addSubViews([titleLabel, collectionView])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview() }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(StoreBridgeCarouselItemCell.Layout.size().height)
        }
    }

    func bind(_ section: StoreRelatedStoresSectionV2) {
        titleLabel.setSDText(section.header.title)
        cards = section.cards
        collectionView.reloadData()
    }
}

extension StoreRelatedStoresV2Cell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: StoreBridgeCarouselItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        if let card = cards[safe: indexPath.item] {
            cell.bind(item: card)
        }
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        StoreBridgeCarouselItemCell.Layout.size()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let card = cards[safe: indexPath.item], let link = card.link else { return }
        onAction?(.link(link, clickLog: card.clickLog))
    }
}
