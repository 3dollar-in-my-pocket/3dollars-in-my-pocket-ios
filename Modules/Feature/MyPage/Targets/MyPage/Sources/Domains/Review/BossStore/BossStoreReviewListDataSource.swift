import UIKit
import Combine

import Model

struct BossStoreReviewListSection: Hashable {
    var items: [BossStoreReviewListSectionItem]
}

enum BossStoreReviewListSectionItem: Hashable {
    case review(MyStoreFeedback)
}

final class BossStoreReviewListDataSource: UICollectionViewDiffableDataSource<BossStoreReviewListSection, BossStoreReviewListSectionItem> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<BossStoreReviewListSection, BossStoreReviewListSectionItem>


    init(collectionView: UICollectionView) {
        collectionView.register([
            BossStoreReviewListCell.self,
        ])

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .review(let feedback):
                let cell: BossStoreReviewListCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(feedback)
                return cell
            }
        }
    }

    func reload(_ sections: [BossStoreReviewListSection]) {
        var snapshot = Snapshot()

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}
