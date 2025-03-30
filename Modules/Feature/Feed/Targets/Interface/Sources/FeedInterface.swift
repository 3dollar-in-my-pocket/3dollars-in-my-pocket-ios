import UIKit

import Common
import Networking

public protocol FeedInterface {
    
}

public struct FeedListViewModelConfig {
    public var mapLatitude: Double?
    public var mapLongitude: Double?
    
    public init(mapLatitude: Double? = nil, mapLongitude: Double? = nil) {
        self.mapLatitude = mapLatitude
        self.mapLongitude = mapLongitude
    }
}

public struct FeedListViewModelDependency {
    let feedRepository: FeedRepository
    
    public init(feedRepository: FeedRepository = FeedRepositoryImpl()) {
        self.feedRepository = feedRepository
    }
}
