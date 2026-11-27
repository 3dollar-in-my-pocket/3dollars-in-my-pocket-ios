import UIKit
import Combine

import Common
import Model
import Networking
import Log

public protocol FeedInterface {
    func createLocalNewsViewController() -> LocalNewsViewControllerType
}

public protocol LocalNewsViewControllerType: UIViewController {
    var scrollView: UIScrollView { get }
    var sectionImpressionLog: AnyPublisher<SDImpressionLog, Never> { get }

    func load(newsTabId: String, mapLatitude: Double, mapLongitude: Double, maxDistanceM: Double?)
    func scrollToTop()
}

public struct FeedListViewModelDependency {
    public let screenRepository: ScreenRepository
    public let logManager: LogManagerProtocol

    public init(
        screenRepository: ScreenRepository = ScreenRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.screenRepository = screenRepository
        self.logManager = logManager
    }
}
