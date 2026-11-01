import UIKit

import DependencyInjection
import FeedInterface

public final class FeedInterfaceImpl: FeedInterface {
    public func createLocalNewsViewController() -> LocalNewsViewControllerType {
        return FeedListViewController(viewModel: FeedListViewModel())
    }

    public static func registerFeedInterface() {
        DIContainer.shared.container.register(FeedInterface.self) { _ in
            return FeedInterfaceImpl()
        }
    }
}
