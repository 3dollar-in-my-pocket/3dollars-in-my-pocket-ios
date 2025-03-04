import UIKit

import Common

final class ReviewListDatasource: UICollectionViewDiffableDataSource<ReviewListSection, ReviewListSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<ReviewListSection, ReviewListSectionItem>
    
    private let viewModel: ReviewListViewModel
    
    init(collection: UICollectionView, viewModel: ReviewListViewModel, vc: UIViewController) {
        self.viewModel = viewModel
        
        collection.register([
            ReviewListCell.self,
            FilteredReviewCell.self
        ])
        
        super.init(collectionView: collection) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .review(let review):
                let cell: ReviewListCell = collection.dequeueReusableCell(indexPath: indexPath)
                cell.containerViewController = vc
                cell.bind(review)
                cell.rightButton.controlPublisher(for: .touchUpInside)
                    .map { _ in indexPath.item }
                    .subscribe(viewModel.input.didTapRightButton)
                    .store(in: &cell.cancellables)
                cell.likeButton.controlPublisher(for: .touchUpInside)
                    .throttle(for: 1, scheduler: RunLoop.main, latest: false)
                    .map { _ in indexPath.item }
                    .subscribe(viewModel.input.didTapReviewLikeButton)
                    .store(in: &cell.cancellables)
                
                return cell
                
            case .filtered:
                let cell: FilteredReviewCell = collection.dequeueReusableCell(indexPath: indexPath)
                
                return cell
            }
        }
        collection.delegate = self
    }
    
    func reload(_ sections: [ReviewListSection]) {
        var snapshot = Snapshot()
        
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot, animatingDifferences: false)
    }
}

extension ReviewListDatasource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }
}
