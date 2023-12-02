import UIKit

import Common
import Model

struct CommunityPollListCellSection: Hashable {
    var items: [CommunityPollListCellSectionItem]
}

enum CommunityPollListCellSectionItem: Hashable {
    case poll(PollItemCellViewModel)
}

final class CommunityPollListCellDataSource: UICollectionViewDiffableDataSource<CommunityPollListCellSection, CommunityPollListCellSectionItem> {

    private typealias Snapshot = NSDiffableDataSourceSnapshot<CommunityPollListCellSection, CommunityPollListCellSectionItem>

    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .poll(let viewModel):
                let cell: PollItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
            }
        }

        collectionView.register([PollItemCell.self])
    }

    func reloadData(_ sections: [CommunityPollListCellSection]) {
        var snapshot = Snapshot()

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}
