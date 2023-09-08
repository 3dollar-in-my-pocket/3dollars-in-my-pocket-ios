import UIKit

final class StoreDetailDatasource: UICollectionViewDiffableDataSource<StoreDetailSection, StoreDetailSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<StoreDetailSection, StoreDetailSectionItem>
    
    init(collectionView: UICollectionView) {
        
        collectionView.register([
            StoreDetailOverviewCell.self
        ])
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .overview:
                let cell: StoreDetailOverviewCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                return cell
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
