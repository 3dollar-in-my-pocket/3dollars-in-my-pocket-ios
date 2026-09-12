import UIKit

import Common

/// 채택한 셀은 스크롤 시 컬렉션뷰 상단(네비바 하단)에 고정된다.
/// StoreSectionsViewController 가 셀 노출 시점에 채택 여부를 보고 고정 대상으로 등록한다.
protocol StickyCell where Self: UICollectionViewCell { }

/// StickyCell 을 채택한 셀을 컬렉션뷰 상단에 고정시키는 레이아웃.
final class StickySectionLayout: UICollectionViewCompositionalLayout {
    private var stickyIndexPaths: Set<IndexPath> = []

    func registerIfNeeded(cell: UICollectionViewCell, indexPath: IndexPath) {
        guard cell is StickyCell else { return }
        stickyIndexPaths.insert(indexPath)
    }

    func clear() {
        stickyIndexPaths.removeAll()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView, stickyIndexPaths.isEmpty.isNot else {
            return super.layoutAttributesForElements(in: rect)
        }

        var attributes = super.layoutAttributesForElements(in: rect)?
            .compactMap { $0.copy() as? UICollectionViewLayoutAttributes } ?? []
        let pinnedY = collectionView.contentOffset.y + collectionView.adjustedContentInset.top

        for indexPath in stickyIndexPaths {
            guard indexPath.section < collectionView.numberOfSections,
                  indexPath.item < collectionView.numberOfItems(inSection: indexPath.section) else { continue }

            if let index = attributes.firstIndex(where: {
                $0.indexPath == indexPath && $0.representedElementCategory == .cell
            }) {
                pinIfNeeded(attributes[index], to: pinnedY)
            } else if let stickyAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes,
                      stickyAttributes.frame.minY < pinnedY {
                // 원래 위치가 조회 rect 밖으로 스크롤되어도 고정 상태를 유지해야 하므로 직접 추가한다.
                pinIfNeeded(stickyAttributes, to: pinnedY)
                attributes.append(stickyAttributes)
            }
        }
        return attributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }

        if let collectionView, stickyIndexPaths.contains(indexPath) {
            let pinnedY = collectionView.contentOffset.y + collectionView.adjustedContentInset.top
            pinIfNeeded(attributes, to: pinnedY)
        }
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if stickyIndexPaths.isEmpty.isNot {
            return true
        }
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        guard let collectionView,
              collectionView.bounds.size == newBounds.size,
              stickyIndexPaths.isEmpty.isNot else { return context }

        // 스크롤로 인한 bounds 변화에는 고정 셀만 무효화한다.
        // 전체 무효화 시 estimated 높이가 다시 계산되며 다른 셀들이 순간적으로 흔들리는 문제가 있다.
        context.invalidateItems(at: Array(stickyIndexPaths))
        return context
    }

    private func pinIfNeeded(_ attributes: UICollectionViewLayoutAttributes, to pinnedY: CGFloat) {
        guard attributes.frame.minY < pinnedY else { return }
        attributes.frame.origin.y = pinnedY
        attributes.zIndex = 1000
    }
}
