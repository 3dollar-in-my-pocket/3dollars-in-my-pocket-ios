import UIKit

import Combine

struct PollListSection: Hashable {
    var items: [PollListSectionItem]
}

enum PollListSectionItem: Hashable {
    case poll(PollItemCellViewModel)
}

final class PollListDataSource: UICollectionViewDiffableDataSource<PollListSection, PollListSectionItem> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<PollListSection, PollListSectionItem>


    init(collectionView: UICollectionView) {
        collectionView.register([
            PollItemCell.self,
        ])

        collectionView.registerSectionHeader([
            PollHeaderView.self,
        ])

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .poll(let cellViewModel):
                let cell: PollItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel: cellViewModel)
                return cell
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

    func reload(_ sections: [PollListSection]) {
        var snapshot = Snapshot()

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}
