import UIKit
import Combine

import Model

struct StoreReviewListSection: Hashable {
    var items: [StoreReviewListSectionItem]
}

enum StoreReviewListSectionItem: Hashable {
    case review(MyStoreReview)
}

final class StoreReviewListDataSource: UICollectionViewDiffableDataSource<StoreReviewListSection, StoreReviewListSectionItem> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<StoreReviewListSection, StoreReviewListSectionItem>

    init(collectionView: UICollectionView) {
        collectionView.register([
            StoreReviewListCell.self,
        ])

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .review(let item):
                let cell: StoreReviewListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(item)
                return cell
            }
        }
    }

    func reload(_ sections: [StoreReviewListSection]) {
        var snapshot = Snapshot()

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}
