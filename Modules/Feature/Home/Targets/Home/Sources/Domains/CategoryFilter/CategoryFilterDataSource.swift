import UIKit

import Model

typealias CategoryFilterSnapShot = NSDiffableDataSourceSnapshot<CategorySection, CategorySectionItem>

final class CategoryFilterDataSource: UICollectionViewDiffableDataSource<CategorySection, CategorySectionItem> {
    let viewModel: CategoryFilterViewModel
    
    init(
        collectionView: UICollectionView,
        viewModel: CategoryFilterViewModel,
        rootViewController: UIViewController
    ) {
        self.viewModel = viewModel
        
        collectionView.register([
            CategoryBannerCell.self,
            CategoryFilterCell.self,
            CategoryAdvertisementCell.self
        ])
        collectionView.registerSectionHeader([CategoryFilterHeaderView.self])
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .category(let category):
                let cell: CategoryFilterCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(category: category)
                return cell
                
            case .advertisement(let advertisement):
                let cell: CategoryBannerCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(advertisement: advertisement, in: rootViewController)
                return cell
            case .categoryAdvertisement(let advertisement):
                let cell: CategoryAdvertisementCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                
                cell.bind(advertisement: advertisement)
                return cell
            }
        }
        
        self.supplementaryViewProvider = { [weak self] collectionView, type, indexPath -> UICollectionReusableView? in
            guard let section = self?.sectionIdentifier(section: indexPath.section) else { return nil }
            
            let headerView: CategoryFilterHeaderView = collectionView.dequeueReusableSupplementaryView(
                ofkind: UICollectionView.elementKindSectionHeader,
                indexPath: indexPath
            )
            headerView.bind(title: section.title, isFirst: indexPath.section == 0)
            return headerView
        }
        
        collectionView.delegate = self
    }
    
    func reload(_ sections: [CategorySection]) {
        var snapshot = CategoryFilterSnapShot()
        
        sections.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }
        
        apply(snapshot, animatingDifferences: true)
    }
}

extension CategoryFilterDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            viewModel.input.onTapBanner.send(())
        } else {
            guard let section = snapshot().sectionIdentifiers[safe: indexPath.section],
                  let item = section.items[safe: indexPath.row] else { return }
            
            switch item {
            case .category(let category):
                viewModel.input.onTapCategory.send(category.categoryId)
            case .categoryAdvertisement(let advertisement):
                viewModel.input.onTapCategoryAdvertisement.send(advertisement)
            case .advertisement:
                break
            }
        }
    }
}
