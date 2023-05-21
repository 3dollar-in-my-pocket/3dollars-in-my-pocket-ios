import UIKit

import RxSwift
import RxCocoa

final class HomeStoreFlowLayout: UICollectionViewFlowLayout {
    let currentIndex = PublishRelay<Int>()
    
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
                
                var currentIndex = Int(round(nextPage))
                
                if currentIndex < 0 {
                    currentIndex = 0
                }
                self.currentIndex.accept(currentIndex)
            } else {
                resultContentOffset.x = round(rawPageValue) * self.pageWidth
                
                var currentIndex = Int(round(rawPageValue))
                
                if currentIndex < 0 {
                    currentIndex = 0
                }
                self.currentIndex.accept(currentIndex)
            }
            resultContentOffset.x -= self.collectionView?.contentInset.left ?? 0
        }
        
        return resultContentOffset
    }
}
