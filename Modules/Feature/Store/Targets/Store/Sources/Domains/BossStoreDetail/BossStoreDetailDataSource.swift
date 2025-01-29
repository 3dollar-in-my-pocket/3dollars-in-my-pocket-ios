import UIKit

import Combine
import Model
import DesignSystem

final class BossStoreDetailDataSource: UICollectionViewDiffableDataSource<BossStoreDetailSection, BossStoreDetailSectionItem> {

    private typealias Snapshot = NSDiffableDataSourceSnapshot<BossStoreDetailSection, BossStoreDetailSectionItem>
    
    private weak var viewModel: BossStoreDetailViewModel?

    init(collectionView: UICollectionView, containerVC: UIViewController, viewModel: BossStoreDetailViewModel?) {
        self.viewModel = viewModel
        
        collectionView.register([
            StoreDetailOverviewCell.self,
            BossStoreInfoCell.self,
            BossStoreMenuListCell.self,
            BossStoreEmptyMenuCell.self,
            BossStoreWorkdayCell.self,
            BossStoreFeedbacksCell.self,
            BossStorePostCell.self,
            StoreDetailRatingCell.self,
            BossStoreDetailReviewCell.self,
            StoreDetailReviewEmptyCell.self,
            StoreDetailReviewMoreCell.self,
            BossStoreDetailReviewFeedbackSummaryCell.self
        ])
        
        collectionView.register(
            BossStoreDetailReviewHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(BossStoreDetailReviewHeaderView.self)"
        )
        
        super.init(collectionView: collectionView) { [weak containerVC, viewModel] collectionView, indexPath, itemIdentifier in
            guard let containerVC, let viewModel else { return UICollectionViewCell() }
            switch itemIdentifier {
            case .overview(let viewModel):
                let cell: StoreDetailOverviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel, rootViewController: containerVC)
                return cell
            case .info(let viewModel):
                let cell: BossStoreInfoCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell
            case .menuList(let viewModel):
                let cell: BossStoreMenuListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell
            case .emptyMenu:
                let cell: BossStoreEmptyMenuCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                return cell
            case .workday(let days):
                let cell: BossStoreWorkdayCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(appearanceDays: days)
                return cell
            case .feedbacks(let viewModel):
                let cell: BossStoreFeedbacksCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
            case .post(let viewModel):
                let cell: BossStorePostCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell
            case .review(let viewModel):
                let cell: BossStoreDetailReviewCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell
            case .reviewRating(let rating):
                let cell: StoreDetailRatingCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(rating)
                return cell
            case .reviewEmpty:
                let cell: StoreDetailReviewEmptyCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.updateBackgroundColor(.clear)
                return cell
            case .reviewMore(let totalCount):
                let cell: StoreDetailReviewMoreCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.moreButton.backgroundColor = Colors.gray10.color
                cell.bind(totalCount)
                return cell
            case .reviewFeedbackSummary(let viewModel):
                let cell: BossStoreDetailReviewFeedbackSummaryCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.bind(viewModel: viewModel)
                return cell
            }
        }
        
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let section = self?.sectionIdentifier(section: indexPath.section) else { return nil }
            
            switch section.type {
            case .review:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "\(BossStoreDetailReviewHeaderView.self)",
                    for: indexPath
                ) as? BossStoreDetailReviewHeaderView else { return UICollectionViewCell() }
                
                headerView.bind(section.header)
                /*
                headerView.rightButton
                    .controlPublisher(for: .touchUpInside)
                    .mapVoid
                    .subscribe(viewModel.input.didTapWriteReview)
                    .store(in: &headerView.cancellables)
                 */
                
                return headerView
            default:
                return nil
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
