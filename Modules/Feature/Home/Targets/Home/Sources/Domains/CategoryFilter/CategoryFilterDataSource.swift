import UIKit

typealias CategoryFilterSanpshot = NSDiffableDataSourceSnapshot<CategorySection, CategorySectionItem>

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
            CategoryFilterCell.self
        ])
        collectionView.register(
            CategoryFilterHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CategoryFilterHeaderView.registerId
        )
        
        super.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .category(let category):
                let cell: CategoryFilterCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                cell.bind(category: category)
                return cell
                
            case .advertisement(let advertisement):
                let cell: CategoryBannerCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
                
                cell.bind(advertisement: advertisement, in: rootViewController)
                return cell
            }
        }
        
        self.supplementaryViewProvider = { [weak self] collectionView, type, indexPath -> UICollectionReusableView? in
            guard let section = self?.sectionIdentifier(section: indexPath.section) else { return nil }
            
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: CategoryFilterHeaderView.registerId,
                for: indexPath
            ) as? CategoryFilterHeaderView
            
            headerView?.bind(title: section.title, isFirst: indexPath.section == 0)
            return headerView
        }
        
        collectionView.delegate = self
    }
}

extension CategoryFilterDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            viewModel.input.onTapBanner.send(())
        } else {
            guard let section = snapshot().sectionIdentifiers[safe: indexPath.section],
                  let item = section.items[safe: indexPath.row],
                  case .category(let category) = item else { return }
            
            viewModel.input.onTapCategory.send(category.categoryId)
        }
    }
}
