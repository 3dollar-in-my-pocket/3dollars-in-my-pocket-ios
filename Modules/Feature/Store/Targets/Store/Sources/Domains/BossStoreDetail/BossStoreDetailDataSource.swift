import UIKit

import Combine

struct BossStoreDetailSection: Hashable {
    enum SectionType {
        case none
    }

    var type: SectionType
    var items: [BossStoreDetailSectionItem]

    func hash(into hasher: inout Hasher) {
        hasher.combine("banner")
    }

    static func == (lhs: BossStoreDetailSection, rhs: BossStoreDetailSection) -> Bool {
        return true
    }
}

enum BossStoreDetailSectionItem: Hashable {
    case none

    func hash(into hasher: inout Hasher) {
        hasher.combine("banner")
    }
}

final class BossStoreDetailDataSource: UICollectionViewDiffableDataSource<BossStoreDetailSection, BossStoreDetailSectionItem> {

    private typealias Snapshot = NSDiffableDataSourceSnapshot<BossStoreDetailSection, BossStoreDetailSectionItem>

    init(collectionView: UICollectionView, containerVC: UIViewController) {
        collectionView.register([])

        collectionView.registerSectionHeader([])

        super.init(collectionView: collectionView) { [weak containerVC] collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .none:
//                let cell: PollDetailContentCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
//                cell.bind(viewModel: cellViewModel)
//                return cell
                return UICollectionViewCell()
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
