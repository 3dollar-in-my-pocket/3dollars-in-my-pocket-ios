import UIKit

final class StoreDetailDatasource: UICollectionViewDiffableDataSource<StoreDetailSection, StoreDetailSectionItem> {
    typealias Snapshot = NSDiffableDataSourceSnapshot<StoreDetailSection, StoreDetailSectionItem>
    
    init(collectionView: UICollectionView) {
        collectionView.register([
            StoreDetailOverviewCell.self,
            StoreDetailVisitCell.self,
            StoreDetailInfoCell.self,
            StoreDetailMenuCell.self
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
                        headerView?.titleLabel.text = "아직 방문 인증 내역이 없어요 :("
                    } else {
                        headerView?.titleLabel.text = "이번 달 방문 인증 내역"
                    }
                }
                
                return headerView
                
            case .info:
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
