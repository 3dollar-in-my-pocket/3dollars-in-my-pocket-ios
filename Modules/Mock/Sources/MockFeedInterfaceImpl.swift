import UIKit
import Combine

import FeedInterface
import Model
import DependencyInjection

public final class MockFeedInterfaceImpl: FeedInterface {
    public func createLocalNewsViewController() -> LocalNewsViewControllerType {
        MockLocalNewsViewController()
    }

    public static func registerFeedInterface() {
        DIContainer.shared.container.register(FeedInterface.self) { _ in
            return MockFeedInterfaceImpl()
        }
    }
}

final class MockLocalNewsViewController: UIViewController, LocalNewsViewControllerType {
    let scrollView = UIScrollView()
    let sectionImpressionLog = Empty<SDImpressionLog, Never>().eraseToAnyPublisher()

    func load(newsTabId: String, mapLatitude: Double, mapLongitude: Double, maxDistanceM: Double?) { }

    func scrollToTop() { }
}
