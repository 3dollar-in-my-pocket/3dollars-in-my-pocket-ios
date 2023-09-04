import UIKit

struct CommunitySection: Hashable {
    var items: [CommunitySectionItem]
}

enum CommunitySectionItem: Hashable {
    case poll
    case store
}

typealias CommunityDataSourceSanpshot = NSDiffableDataSourceSnapshot<CommunitySection, CommunitySectionItem>

final class CommunityDataSource: UICollectionViewDiffableDataSource<CommunitySection, CommunitySectionItem> {
    init(collectionView: UICollectionView) {
        collectionView.register([
            CommunityPollListCell.self,
            CommunityStoreTabCell.self
        ])

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .poll:
                let cell: CommunityPollListCell = collectionView.dequeueReuseableCell(indexPath: indexPath)

                return cell
            case .store:
                let cell: CommunityStoreTabCell = collectionView.dequeueReuseableCell(indexPath: indexPath)

                return cell
            }
        }
    }

    func reloadData() {
        var snapshot = CommunityDataSourceSanpshot()

        let sections = [CommunitySection(items: [
            .poll, .store
        ])]

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}
