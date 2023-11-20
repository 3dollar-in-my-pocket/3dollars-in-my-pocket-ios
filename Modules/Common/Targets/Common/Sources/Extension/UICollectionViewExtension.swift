import UIKit

public extension UICollectionView {
    func register(_ cellTypes: [UICollectionViewCell.Type]) {
        for cellType in cellTypes {
            self.register(cellType, forCellWithReuseIdentifier: "\(cellType.self)")
        }
    }
    
    func registerSectionHeader(_ viewTypes: [UICollectionReusableView.Type]) {
        for viewType in viewTypes {
            self.register(
                viewType,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "\(viewType.self)"
            )
        }
    }
    
    func registerSectionFooter(_ viewTypes: [UICollectionReusableView.Type]) {
        for viewType in viewTypes {
            self.register(
                viewType,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: "\(viewType.self)"
            )
        }
    }
    
    func dequeueReuseableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(
            withReuseIdentifier: "\(T.self)",
            for: indexPath
        ) as? T else { fatalError("정의되지 않은 UICollectionViewCell 입니다.") }
        
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        ofkind: String,
        indexPath: IndexPath
    ) -> T {
        guard let view = self.dequeueReusableSupplementaryView(
            ofKind: ofkind,
            withReuseIdentifier: "\(T.self)",
            for: indexPath
        ) as? T else { fatalError("정의되지 않은 UICollectionReusableView 입니다.") }
        
        return view
    }

    func scrollToBottom(animated: Bool = true) {
        guard numberOfSections > 0 else { return }

        let lastSection = numberOfSections - 1
        let lastItem = numberOfItems(inSection: lastSection) - 1

        let indexPath = IndexPath(
            item: lastItem,
            section: lastSection
        )
        scrollToItemIfAvailable(at: indexPath, at: .bottom, animated: true)
    }

    func scrollToItemIfAvailable(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard isIndexPathAvailable(indexPath) else { return }

        scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }

    func isIndexPathAvailable(_ indexPath: IndexPath) -> Bool {
        guard dataSource != nil,
              indexPath.section < numberOfSections,
              indexPath.item < numberOfItems(inSection: indexPath.section) else {
            return false
        }

        return true
    }
}
