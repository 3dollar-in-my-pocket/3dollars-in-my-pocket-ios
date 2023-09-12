import UIKit

final class StoreDetailDatasource: UICollectionViewDiffableDataSource<StoreDetailSection, StoreDetailSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<StoreDetailSection, StoreDetailSectionItem>
    
    init(collectionView: UICollectionView) {
        collectionView.register([
            StoreDetailOverviewCell.self,
            StoreDetailVisitCell.self
        ])
        
        collectionView.register(
            StoreDetailHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(StoreDetailHeaderView.self)"
        )
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .overview(let data):
                let cell: StoreDetailOverviewCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(data)
                return cell
                
            case .visit:
                let cell: StoreDetailVisitCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
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
