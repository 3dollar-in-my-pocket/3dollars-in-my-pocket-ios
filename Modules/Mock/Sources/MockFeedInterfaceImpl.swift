import UIKit

import FeedInterface
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

    func load(mapLatitude: Double, mapLongitude: Double) { }

    func setVisible(_ isVisible: Bool) { }

    func scrollToTop() { }
}
