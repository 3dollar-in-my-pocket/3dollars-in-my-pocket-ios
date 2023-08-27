import UIKit

import Combine

final class HomeCardFlowLayout: UICollectionViewFlowLayout {
    let currentIndexPublisher = PassthroughSubject<Int, Never>()
    
    var pageWidth: CGFloat {
        return itemSize.width + minimumLineSpacing
    }
    
    var flickVelocity: CGFloat {
        return 0.6
    }
    
    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        var resultContentOffset = proposedContentOffset
        
        if let collectionView = collectionView {
            let rawPageValue = collectionView.contentOffset.x / pageWidth
            let currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue)
            let nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue)
            
            let pannedLessThanAPage = abs(1 + currentPage - rawPageValue) > 0.5
            let flicked = abs(velocity.x) > flickVelocity
            
            if (pannedLessThanAPage && flicked) == true {
                resultContentOffset.x = nextPage * pageWidth
                
                var currentIndex = Int(round(nextPage))
                
                if currentIndex < 0 {
                    currentIndex = 0
                }
                
                currentIndexPublisher.send(currentIndex)
            } else {
                resultContentOffset.x = round(rawPageValue) * pageWidth
                
                var currentIndex = Int(round(rawPageValue))
                
                if currentIndex < 0 {
                    currentIndex = 0
                }
                
                currentIndexPublisher.send(currentIndex)
            }
            resultContentOffset.x -= collectionView.contentInset.left
        }
        
        return resultContentOffset
    }
}
