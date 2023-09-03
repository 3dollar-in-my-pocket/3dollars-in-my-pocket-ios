import UIKit

struct CommunitySection: Hashable {
    var items: [CommunitySectionItem]
}

enum CommunitySectionItem: Hashable {
    case poll
}

typealias CommunityDataSourceSanpshot = NSDiffableDataSourceSnapshot<CommunitySection, CommunitySectionItem>

final class CommunityDataSource: UICollectionViewDiffableDataSource<CommunitySection, CommunitySectionItem> {
    init(collectionView: UICollectionView) {
        collectionView.register([CommunityPollListCell.self])

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .poll:
                let cell: CommunityPollListCell = collectionView.dequeueReuseableCell(indexPath: indexPath)

                return cell
            }
        }
    }

    func reloadData() {
        var snapshot = CommunityDataSourceSanpshot()

        snapshot.appendSections([.init(items: [.poll])])
        snapshot.appendItems([.poll])

        apply(snapshot, animatingDifferences: true)
    }
}
