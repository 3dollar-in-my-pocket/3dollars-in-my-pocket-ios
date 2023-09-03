import UIKit

struct CommunitySection: Hashable {
    var items: [CommunitySectionItem]
}

enum CommunitySectionItem: Hashable {
    case empty
}

final class CommunityDataSource: UICollectionViewDiffableDataSource<CommunitySection, CommunitySectionItem> {
    init(collectionView: UICollectionView) {
        collectionView.register([])

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .empty:
                let cell: UICollectionViewCell = collectionView.dequeueReuseableCell(indexPath: indexPath)

                return cell
            }
        }
    }
}
