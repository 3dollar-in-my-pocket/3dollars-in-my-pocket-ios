import UIKit

import Model

typealias CategorySelectionSnapshot = NSDiffableDataSourceSnapshot<CategorySelectionSection, CategorySelectionItem>

final class CategorySelectionDataSource: UICollectionViewDiffableDataSource<CategorySelectionSection, CategorySelectionItem> {
    let viewModel: CategorySelectionViewModel
    
    init(collectionView: UICollectionView, viewModel: CategorySelectionViewModel) {
        self.viewModel = viewModel
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .category(let category):
                let cell: CategorySelectionCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                cell.bind(category: category)
                return cell
            }
        }
        
        self.supplementaryViewProvider = { [weak self] collectionView, type, indexPath -> UICollectionReusableView? in
            guard let section = self?.sectionIdentifier(section: indexPath.section) else { return nil }
            
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: CategorySelectionHeaderView.registerId,
                for: indexPath
            ) as? CategorySelectionHeaderView
            
            headerView?.bind(title: section.title)
            return headerView
        }
        
        collectionView.register([
            CategorySelectionCell.self
        ])
        collectionView.register(
            CategorySelectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CategorySelectionHeaderView.registerId
        )
        collectionView.delegate = self
    }
    
    func reload(_ sections: [CategorySelectionSection]) {
        var snapshot = CategorySelectionSnapshot()
        
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        apply(snapshot, animatingDifferences: false)
    }
    
    func getIndexPath(of item: CategorySelectionItem) -> IndexPath? {
        let snapshot = snapshot()
        var row: Int?
        var section: Int?
        
        for (sectionIndex, categorySection) in snapshot.sectionIdentifiers.enumerated() {
            if let targetIndex = categorySection.items.firstIndex(where: { $0.id == item.id }) {
                row = targetIndex
                section = sectionIndex
            }
        }
        
        guard let section, let row else { return nil }
        
        return IndexPath(row: row, section: section)
    }
}


extension CategorySelectionDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = snapshot().sectionIdentifiers[safe: indexPath.section],
              let item = section.items[safe: indexPath.row],
              case .category(let category) = item else { return }
        
        viewModel.input.selectCategory.send(category.categoryId)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let section = snapshot().sectionIdentifiers[safe: indexPath.section],
              let item = section.items[safe: indexPath.row],
              case .category(let category) = item else { return }
        
        viewModel.input.deSelectCategory.send(category.categoryId)
    }
}

struct CategorySelectionSection: Hashable {
    enum SectionType: Hashable {
        case category
    }
    
    let type: SectionType
    let title: String
    var items: [CategorySelectionItem]
}

enum CategorySelectionItem: Hashable {
    case category(PlatformStoreCategory)
    
    var id: String {
        switch self {
        case .category(let category):
            return category.categoryId
        }
    }
}
