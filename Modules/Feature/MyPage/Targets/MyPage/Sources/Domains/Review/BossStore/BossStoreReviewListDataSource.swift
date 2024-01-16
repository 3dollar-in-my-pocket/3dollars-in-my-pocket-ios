import UIKit

import Combine

struct BossStoreReviewListSection: Hashable {
    var items: [BossStoreReviewListSectionItem]
}

enum BossStoreReviewListSectionItem: Hashable {
    case review
}

final class BossStoreReviewListDataSource: UICollectionViewDiffableDataSource<BossStoreReviewListSection, BossStoreReviewListSectionItem> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<BossStoreReviewListSection, BossStoreReviewListSectionItem>


    init(collectionView: UICollectionView) {
        collectionView.register([
//            PollItemCell.self,
        ])

        collectionView.registerSectionHeader([
//            PollHeaderView.self,
        ])

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .review:
                return UICollectionViewCell()
            }
        }

        /*
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let _ = self?.sectionIdentifier(section: indexPath.section) else {
                return nil
            }

            let headerView: PollHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
            headerView.bind()
            return headerView
        }
         */
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
