import UIKit

import Combine
import Model

final class BossStoreDetailDataSource: UICollectionViewDiffableDataSource<BossStoreDetailSection, BossStoreDetailSectionItem> {

    private typealias Snapshot = NSDiffableDataSourceSnapshot<BossStoreDetailSection, BossStoreDetailSectionItem>

    init(collectionView: UICollectionView, containerVC: UIViewController) {
        collectionView.register([
            StoreDetailOverviewCell.self,
            BossStoreInfoCell.self,
            BossStoreMenuListCell.self,
            BossStoreEmptyMenuCell.self,
            BossStoreWorkdayCell.self,
            BossStoreFeedbacksCell.self
        ])

        super.init(collectionView: collectionView) { [weak containerVC] collectionView, indexPath, itemIdentifier in
            guard let containerVC else { return UICollectionViewCell() }
            switch itemIdentifier {
            case .overview(let viewModel):
                let cell: StoreDetailOverviewCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel, rootViewController: containerVC)
                return cell
            case .info(let viewModel):
                let cell: BossStoreInfoCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell
            case .menuList(let viewModel):
                let cell: BossStoreMenuListCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell
            case .emptyMenu:
                let cell: BossStoreEmptyMenuCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                return cell
            case .workday(let days):
                let cell: BossStoreWorkdayCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(appearanceDays: days)
                return cell
            case .feedbacks(let viewModel):
                let cell: BossStoreFeedbacksCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
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
