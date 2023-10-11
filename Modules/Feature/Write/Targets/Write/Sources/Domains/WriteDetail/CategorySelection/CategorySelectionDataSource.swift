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
        
        collectionView.register([
            CategorySelectionCell.self
        ])
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
}


extension CategorySelectionDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.selectCategory.send(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.input.deSelectCategory.send(indexPath.row)
    }
}

struct CategorySelectionSection: Hashable {
    enum SectionType: Hashable {
        case category
    }
    
    let type: SectionType
    var items: [CategorySelectionItem]
}

enum CategorySelectionItem: Hashable {
    case category(PlatformStoreCategory)
}
