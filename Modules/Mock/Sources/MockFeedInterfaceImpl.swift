import UIKit

import FeedInterface
import DependencyInjection

public final class MockFeedInterfaceImpl: FeedInterface {
    public func createFeedListViewController(config: FeedListViewModelConfig) -> UIViewController {
        EmptyViewController()
    }

    public static func registerFeedInterface() {
        DIContainer.shared.container.register(FeedInterface.self) { _ in
            return MockFeedInterfaceImpl()
        }
    }
}
