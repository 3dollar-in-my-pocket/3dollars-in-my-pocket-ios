import UIKit

import Common
import Model

struct CommunityPopularStoreNeighborhoodsSection: Hashable {
    var items: [CommunityPopularStoreNeighborhoodsSectionItem]
}

enum CommunityPopularStoreNeighborhoodsSectionItem: Hashable {
    case district(CommunityNeighborhoods)
}

final class CommunityPopularStoreNeighborhoodsDataSource: UICollectionViewDiffableDataSource<CommunityPopularStoreNeighborhoodsSection, CommunityPopularStoreNeighborhoodsSectionItem> {

    private typealias Snapshot = NSDiffableDataSourceSnapshot<CommunityPopularStoreNeighborhoodsSection, CommunityPopularStoreNeighborhoodsSectionItem>

    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .district(let item):
                let cell: CommunityPopularStoreNeighborhoodsCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(item: item)
                return cell
            }
        }

        collectionView.register([CommunityPopularStoreNeighborhoodsCell.self])
    }

    func reloadData(_ sections: [CommunityPopularStoreNeighborhoodsSection]) {
        var snapshot = Snapshot()

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}
