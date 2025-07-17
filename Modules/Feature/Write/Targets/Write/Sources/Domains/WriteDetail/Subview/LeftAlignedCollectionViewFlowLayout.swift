import UIKit

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let originalAttributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        // Copy to avoid modifying the original attributes
        let attributes = originalAttributes.map { $0.copy() as! UICollectionViewLayoutAttributes }

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0

        for attribute in attributes {
            // Skip supplementary views like headers/footers
            if attribute.representedElementCategory != .cell {
                continue
            }

            if attribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            var frame = attribute.frame
            frame.origin.x = leftMargin
            attribute.frame = frame

            leftMargin += frame.width + minimumInteritemSpacing
            maxY = max(frame.maxY, maxY)
        }

        return attributes
    }
}
