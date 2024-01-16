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
    
    func getNearByItemScrollOffset(velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>, sectionInsets: UIEdgeInsets) -> CGPoint? {
        var index = IndexPath(row: 0, section: 0)
        var shortDistance = CGFloat.greatestFiniteMagnitude
        
        indexPathsForVisibleItems.forEach { [weak self] indexPath in
            guard let self else { return }
            
            if let cell = cellForItem(at: indexPath) {
                let compareOriginX = if velocity.x > 0 {
                    abs(bounds.midX - cell.frame.origin.x)
                } else if velocity.x < 0 {
                    abs(targetContentOffset.pointee.x - cell.frame.midX)
                } else {
                    abs(targetContentOffset.pointee.x - cell.frame.origin.x)
                }
                
                if shortDistance > compareOriginX {
                    shortDistance = compareOriginX
                    index = indexPath
                }
            }
        }
        
        if let origin = cellForItem(at: index)?.frame.origin {
            return CGPoint(x: origin.x - sectionInsets.left, y: origin.y)
        }
        
        return nil
    }
}
