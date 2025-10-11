import UIKit
import Combine

import Model
import StoreInterface

struct CouponListSection: Hashable {
    var items: [CouponListSectionItem]
}

enum CouponListSectionItem: Hashable {
    case coupon(BossStoreCouponViewModel)
}

final class CouponListDataSource: UICollectionViewDiffableDataSource<CouponListSection, CouponListSectionItem> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<CouponListSection, CouponListSectionItem>

    init(collectionView: UICollectionView) {
        collectionView.register([
            CouponListCell.self,
        ])

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .coupon(let item):
                let cell: CouponListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel: item)
                return cell
            }
        }
    }

    func reload(_ sections: [CouponListSection]) {
        var snapshot = Snapshot()

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}
