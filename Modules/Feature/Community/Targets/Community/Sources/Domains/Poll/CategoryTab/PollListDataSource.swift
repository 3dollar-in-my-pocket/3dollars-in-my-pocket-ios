import UIKit

import Combine

struct PollListSection: Hashable {
    var items: [PollListSectionItem]
}

enum PollListSectionItem: Hashable {
    case poll(String)
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
            case .poll:
                let cell: PollItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind()
                return cell
            }
        }

        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let _ = self?.sectionIdentifier(section: indexPath.section) else {
                return nil
            }

            let headerView: PollHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
            headerView.bind()
            return headerView
        }

        collectionView.delegate = self
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

extension PollListDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch self[indexPath] {
        case .poll:
            return CGSize(width: UIScreen.main.bounds.width - 40, height: 246)
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: PollHeaderView.Layout.height)
    }
}
