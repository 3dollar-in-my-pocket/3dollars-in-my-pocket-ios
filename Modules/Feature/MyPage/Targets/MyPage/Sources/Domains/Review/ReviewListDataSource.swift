import UIKit

import Combine

struct ReviewListSection: Hashable {
    var items: [ReviewListSectionItem]
}

enum ReviewListSectionItem: Hashable {
    case review
}

final class ReviewListDataSource: UICollectionViewDiffableDataSource<ReviewListSection, ReviewListSectionItem> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<ReviewListSection, ReviewListSectionItem>


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

    func reload(_ sections: [ReviewListSection]) {
        var snapshot = Snapshot()

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}
