import UIKit
import Combine

import Model

struct VisitStoreListSection: Hashable {
    var visitDate: String
    var items: [VisitStoreListSectionItem]
}

enum VisitStoreListSectionItem: Hashable {
    case store(MyVisitStore)
}

final class VisitStoreListDataSource: UICollectionViewDiffableDataSource<VisitStoreListSection, VisitStoreListSectionItem> {

    typealias Snapshot = NSDiffableDataSourceSnapshot<VisitStoreListSection, VisitStoreListSectionItem>

    init(collectionView: UICollectionView) {
        collectionView.register([
            VisitStoreItemCell.self,
        ])
        
        collectionView.registerSectionHeader([
            VisitStoreHeaderView.self
        ])

        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .store(let item):
                let cell: VisitStoreItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                cell.bind(item: item)
                return cell
            }
        }
        
        supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let section = self?.sectionIdentifier(section: indexPath.section) else {
                return nil
            }
            
            let headerView: VisitStoreHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
            headerView.bind(section.visitDate)
            return headerView
        }
    }

    func reload(_ sections: [VisitStoreListSection]) {
        var snapshot = Snapshot()

        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }

        apply(snapshot, animatingDifferences: true)
    }
}
