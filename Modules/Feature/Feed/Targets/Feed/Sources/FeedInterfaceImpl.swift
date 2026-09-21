import UIKit

import DependencyInjection
import FeedInterface

public final class FeedInterfaceImpl: FeedInterface {
    public func createFeedListViewController(config: FeedListViewModelConfig) -> UIViewController {
        let viewModel = FeedListViewModel(config: config)
        return FeedListViewController(viewModel: viewModel)
    }

    public static func registerFeedInterface() {
        DIContainer.shared.container.register(FeedInterface.self) { _ in
            return FeedInterfaceImpl()
        }
    }
}
