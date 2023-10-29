import UIKit

import Combine

struct BossStoreDetailSection: Hashable {
    enum SectionType: Hashable {
        case overview
    }

    var type: SectionType
    var items: [BossStoreDetailSectionItem]
}

enum BossStoreDetailSectionItem: Hashable {
    case overview(StoreDetailOverviewCellViewModel)
}

final class BossStoreDetailDataSource: UICollectionViewDiffableDataSource<BossStoreDetailSection, BossStoreDetailSectionItem> {

    private typealias Snapshot = NSDiffableDataSourceSnapshot<BossStoreDetailSection, BossStoreDetailSectionItem>

    init(collectionView: UICollectionView, containerVC: UIViewController) {
        collectionView.register([StoreDetailOverviewCell.self])

        collectionView.registerSectionHeader([])

        super.init(collectionView: collectionView) { [weak containerVC] collectionView, indexPath, itemIdentifier in
            guard let containerVC else { return UICollectionViewCell() }
            switch itemIdentifier {
            case .overview(let viewModel):
                let cell: StoreDetailOverviewCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel, rootViewController: containerVC)
                return cell
            default:
                return UICollectionViewCell()
            }
        }

//        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
//            guard let section = self?.sectionIdentifier(section: indexPath.section) else {
//                return nil
//            }
//
//            switch section.type {
//            case .comment(let totalCount):
//                let headerView: PollDetailCommentHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
//                headerView.bind(count: totalCount)
//                return headerView
//            default:
//                return nil
//            }
//        }
    }

    func reloadData(_ sections: [BossStoreDetailSection]) {
        var snapshot = Snapshot()

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: false)
    }
}
