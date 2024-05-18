import UIKit

import Common

final class StoreDetailDatasource: UICollectionViewDiffableDataSource<StoreDetailSection, StoreDetailSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<StoreDetailSection, StoreDetailSectionItem>
    private let viewModel: StoreDetailViewModel
    
    init(
        collectionView: UICollectionView,
        viewModel: StoreDetailViewModel,
        rootViewController: UIViewController
    ) {
        self.viewModel = viewModel
        collectionView.register([
            StoreDetailOverviewCell.self,
            StoreDetailVisitCell.self,
            StoreDetailInfoCell.self,
            StoreDetailMenuCell.self,
            StoreDetailPhotoCell.self,
            StoreDetailRatingCell.self,
            StoreDetailReviewCell.self,
            StoreDetailReviewMoreCell.self,
            StoreDetailReviewEmptyCell.self,
            StoreDetailFilteredReviewCell.self
        ])
        
        collectionView.register(
            StoreDetailHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(StoreDetailHeaderView.self)"
        )
        collectionView.register(
            StoreDetailPhotoFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "\(StoreDetailPhotoFooterView.self)")
        
        super.init(collectionView: collectionView) { [weak rootViewController] collectionView, indexPath, itemIdentifier in
            guard let rootViewController else { return UICollectionViewCell() }
            switch itemIdentifier {
            case .overview(let viewModel):
                let cell: StoreDetailOverviewCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(viewModel, rootViewController: rootViewController)
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
                cell.rightButton
                    .controlPublisher(for: .touchUpInside)
                    .map { _ in indexPath.item - 1 }
                    .subscribe(viewModel.input.didTapReviewRightButton)
                    .store(in: &cell.cancellables)
                cell.likeButton
                    .controlPublisher(for: .touchUpInside)
                    .map { _ in indexPath.item - 1 }
                    .subscribe(viewModel.input.didTapReviewLikeButton)
                    .store(in: &cell.cancellables)
                
                return cell
                
            case .reviewMore(let totalCount):
                let cell: StoreDetailReviewMoreCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(totalCount)
                cell.moreButton.controlPublisher(for: .touchUpInside)
                    .mapVoid
                    .subscribe(viewModel.input.didTapReviewMore)
                    .store(in: &cell.cancellables)
                return cell
                
            case .reviewEmpty:
                let cell: StoreDetailReviewEmptyCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                return cell
                
            case .filteredReview:
                let cell: StoreDetailFilteredReviewCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
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
                
            case .info:
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "\(StoreDetailHeaderView.self)",
                    for: indexPath
                ) as? StoreDetailHeaderView
                
                guard let headerView else { return BaseCollectionViewReusableView() }
                headerView.bind(section.header)
                headerView.rightButton
                    .controlPublisher(for: .touchUpInside)
                    .mapVoid
                    .subscribe(viewModel.input.didTapEdit)
                    .store(in: &headerView.cancellables)
                
                return headerView
                
            case .photo(let totalCount):
                if kind == UICollectionView.elementKindSectionHeader {
                    let headerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: "\(StoreDetailHeaderView.self)",
                        for: indexPath
                    ) as? StoreDetailHeaderView
                    
                    guard let headerView else { return BaseCollectionViewReusableView() }
                    headerView.bind(section.header)
                    headerView.rightButton
                        .controlPublisher(for: .touchUpInside)
                        .mapVoid
                        .subscribe(viewModel.input.didTapUploadPhoto)
                        .store(in: &headerView.cancellables)
                    
                    return headerView
                } else {
                    let footerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionFooter,
                        withReuseIdentifier: "\(StoreDetailPhotoFooterView.self)",
                        for: indexPath
                    ) as? StoreDetailPhotoFooterView
                    
                    footerView?.bind(totalCount)
                    return footerView
                }
                
            case .review:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: "\(StoreDetailHeaderView.self)",
                    for: indexPath
                ) as? StoreDetailHeaderView else { return BaseCollectionViewCell() }
                
                headerView.bind(section.header)
                headerView.rightButton
                    .controlPublisher(for: .touchUpInside)
                    .mapVoid
                    .subscribe(viewModel.input.didTapWriteReview)
                    .store(in: &headerView.cancellables)
                
                return headerView
            }
        }
        collectionView.delegate = self
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

extension StoreDetailDatasource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = sectionIdentifier(section: indexPath.section),
              case .photo(_) = section.type else { return }
        
        viewModel.input.didTapPhoto.send(indexPath.item)
    }
}
