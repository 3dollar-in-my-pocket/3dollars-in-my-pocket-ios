import UIKit

import RxSwift

final class HomeStoreFlowLayout: UICollectionViewFlowLayout {
    var pageWidth: CGFloat {
        return self.itemSize.width + self.minimumLineSpacing
    }
    
    var flickVelocity: CGFloat {
        return 0.6
    }
    
    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        var resultContentOffset = proposedContentOffset
        
        if let collectionView = self.collectionView {
            let rawPageValue = collectionView.contentOffset.x / self.pageWidth
            let currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue)
            let nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue)
            
            let pannedLessThanAPage = abs(1 + currentPage - rawPageValue) > 0.5
            let flicked = abs(velocity.x) > self.flickVelocity
            
            if (pannedLessThanAPage && flicked) == true {
                resultContentOffset.x = nextPage * self.pageWidth
            } else {
                resultContentOffset.x = round(rawPageValue) * self.pageWidth
            }
            resultContentOffset.x -= self.collectionView?.contentInset.left ?? 0
        }
        
        return resultContentOffset
    }
}
