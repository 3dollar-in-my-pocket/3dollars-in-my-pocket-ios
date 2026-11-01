import UIKit

open class WidthAdaptiveFlowLayout: UICollectionViewFlowLayout {
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if isWidthChanged(newBounds) {
            return true
        }
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }

    open override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        if isWidthChanged(newBounds), let flowContext = context as? UICollectionViewFlowLayoutInvalidationContext {
            flowContext.invalidateFlowLayoutDelegateMetrics = true
        }
        return context
    }

    private func isWidthChanged(_ newBounds: CGRect) -> Bool {
        guard let collectionView else { return false }
        return newBounds.width != collectionView.bounds.width
    }
}
