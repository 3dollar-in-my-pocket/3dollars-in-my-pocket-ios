import UIKit

final class StoreDetailDatasource: UICollectionViewDiffableDataSource<StoreDetailSection, StoreDetailSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<StoreDetailSection, StoreDetailSectionItem>
    
    init(collectionView: UICollectionView) {
        collectionView.register([
            StoreDetailOverviewCell.self,
            StoreDetailVisitCell.self,
            StoreDetailInfoCell.self,
            StoreDetailMenuCell.self,
            StoreDetailPhotoCell.self,
            StoreDetailRatingCell.self,
            StoreDetailReviewCell.self,
            StoreDetailReviewMoreCell.self
        ])
        
        collectionView.register(
            StoreDetailHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(StoreDetailHeaderView.self)"
        )
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .overview(let viewModel):
                let cell: StoreDetailOverviewCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel)
                return cell
                
            case .visit(let data):
                let cell: StoreDetailVisitCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(data)
                return cell
                
            case .info(let data):
                let cell: StoreDetailInfoCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(data)
                return cell
                
            case .menu(let menus):
                let cell: StoreDetailMenuCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(menus)
                return cell
                
            case .photo(let photo):
                let cell: StoreDetailPhotoCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                if indexPath.item == 3 {
                    cell.bind(photo: photo, isLast: true)
                } else {
                    cell.bind(photo: photo, isLast: false)
                }
                return cell
                
            case .rating(let rating):
                let cell: StoreDetailRatingCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(rating)
                return cell
                
            case .review(let review):
                let cell: StoreDetailReviewCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(review)
                return cell
                
            case .reviewMore(let totalCount):
                let cell: StoreDetailReviewMoreCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(totalCount)
                return cell
            }
        }
        
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let section = self?.sectionIdentifier(section: indexPath.section) else { return nil }
            
            switch section.type {
            case .overview:
                return nil
                
            case .visit:
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "\(StoreDetailHeaderView.self)",
                    for: indexPath
                ) as? StoreDetailHeaderView
                
                if case .visit(let storeDetailVisit) = section.items.first {
                    if storeDetailVisit.histories.isEmpty {
                        headerView?.titleLabel.text = Strings.StoreDetail.Visit.Header.titleEmpty
                    } else {
                        headerView?.titleLabel.text = Strings.StoreDetail.Visit.Header.titleNormal
                    }
                }
                
                return headerView
                
            case .info, .photo, .review:
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "\(StoreDetailHeaderView.self)",
                    for: indexPath
                ) as? StoreDetailHeaderView
                
                headerView?.bind(section.header)
                
                
                return headerView
            }
        }
    }
    
    func reload(_ sections: [StoreDetailSection]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot, animatingDifferences: false)
    }
}
