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
                return UICollectionViewCell()
            default:
                return UICollectionViewCell()
            }
        }
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
