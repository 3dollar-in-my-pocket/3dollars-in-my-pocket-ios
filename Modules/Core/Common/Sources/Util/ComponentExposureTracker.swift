import UIKit
import Combine

public final class ComponentExposureTracker {
    // MARK: - Configuration
    public struct Configuration {
        let visibilityThreshold: CGFloat // 노출 임계값 (0.0 ~ 1.0)
        let throttleInterval: CFTimeInterval // 스크롤 체크 간격
        
        public init(
            visibilityThreshold: CGFloat = 0.5, // 기본값 50%
            throttleInterval: CFTimeInterval = 0.1 // 기본값 100ms
        ) {
            self.visibilityThreshold = max(0.0, min(1.0, visibilityThreshold))
            self.throttleInterval = max(0.0, throttleInterval)
        }
    }
    
    // MARK: - Properties
    private let configuration: Configuration
    private var lastScrollCheckTime: CFTimeInterval = 0
    private weak var collectionView: UICollectionView?
    
    // MARK: - Initialization
    public init(collectionView: UICollectionView, configuration: Configuration = Configuration()) {
        self.collectionView = collectionView
        self.configuration = configuration
    }
    
    // MARK: - Public Methods
    public func handleWillDisplay(
        cell: UICollectionViewCell,
        at indexPath: IndexPath,
        exposureHandler: @escaping (UICollectionViewCell, IndexPath) -> Void
    ) {
        checkComponentExposure(cell: cell, at: indexPath, exposureHandler: exposureHandler)
    }
    
    public func handleScroll(exposureHandler: @escaping (UICollectionViewCell, IndexPath) -> Void) {
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastScrollCheckTime >= configuration.throttleInterval else { return }
        lastScrollCheckTime = currentTime
        
        checkAllComponentExposure(exposureHandler: exposureHandler)
    }
    
    // MARK: - Private Methods
    private func checkAllComponentExposure(exposureHandler: @escaping (UICollectionViewCell, IndexPath) -> Void) {
        guard let collectionView = collectionView else { return }
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        
        for indexPath in visibleIndexPaths {
            if let cell = collectionView.cellForItem(at: indexPath) {
                checkComponentExposure(cell: cell, at: indexPath, exposureHandler: exposureHandler)
            }
        }
    }
    
    private func checkComponentExposure(
        cell: UICollectionViewCell,
        at indexPath: IndexPath,
        exposureHandler: @escaping (UICollectionViewCell, IndexPath) -> Void
    ) {
        guard let collectionView = collectionView else { return }
        
        let cellFrame = cell.frame
        let visibleRect = collectionView.bounds
        let intersection = cellFrame.intersection(visibleRect)
        
        let visibilityRatio = calculateVisibilityRatio(
            cellFrame: cellFrame,
            intersection: intersection
        )
        
        guard visibilityRatio >= configuration.visibilityThreshold else { return }
        
        exposureHandler(cell, indexPath)
    }
    
    private func calculateVisibilityRatio(cellFrame: CGRect, intersection: CGRect) -> CGFloat {
        guard cellFrame.width > 0, cellFrame.height > 0 else { return 0.0 }
        
        let cellArea = cellFrame.width * cellFrame.height
        let visibleArea = intersection.width * intersection.height
        
        return visibleArea / cellArea
    }
}
