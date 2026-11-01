import UIKit

import Common
import Networking

public protocol FeedInterface {
    func createLocalNewsViewController() -> LocalNewsViewControllerType
}

public protocol LocalNewsViewControllerType: UIViewController {
    var scrollView: UIScrollView { get }

    func load(mapLatitude: Double, mapLongitude: Double)
    func setVisible(_ isVisible: Bool)
    func scrollToTop()
}

public struct FeedListViewModelDependency {
    public let feedRepository: FeedRepository
    public let advertisementRepository: AdvertisementRepository
    
    public init(
        feedRepository: FeedRepository = FeedRepositoryImpl(),
        advertisementRepository: AdvertisementRepository = AdvertisementRepositoryImpl()
    ) {
        self.feedRepository = feedRepository
        self.advertisementRepository = advertisementRepository
    }
}
