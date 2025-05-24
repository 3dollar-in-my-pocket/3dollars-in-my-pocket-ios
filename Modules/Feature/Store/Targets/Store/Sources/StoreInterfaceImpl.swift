import UIKit
import Combine

import DependencyInjection
import StoreInterface
import Model

public final class StoreInterfaceImpl: StoreInterface {
    public func getStoreDetailViewController(storeId: Int) -> UIViewController {
        return StoreDetailViewController.instance(storeId: storeId)
    }

    public func getBossStoreDetailViewController(
        storeId: String,
        shouldPushReviewList: Bool
    ) -> UIViewController {
        return BossStoreDetailViewController.instance(storeId: storeId, shouldPushReviewList: shouldPushReviewList)
    }

    public func getVisitViewController(storeId: Int, onSuccessVisit: @escaping (() -> Void)) -> UIViewController {
        let config = VisitViewModel.Config(storeId: String(storeId))
        let viewModel = VisitViewModel(config: config)
        
        viewModel.output.onSuccessVisit
            .sink { _ in
                onSuccessVisit()
            }
            .store(in: &viewModel.cancellables)
        
        return VisitViewController(viewModel: viewModel)
    }
    
    public func getMapDetailViewController(location: LocationResponse, storeName: String) -> UIViewController {
        let config = MapDetailViewModel.Config(location: location, storeName: storeName)
        let viewModel = MapDetailViewModel(config: config)
        let viewController = MapDetailViewController(viewModel: viewModel)
        
        return viewController
    }
}

public extension StoreInterfaceImpl {
    static func registerStoreInterface() {
        DIContainer.shared.container.register(StoreInterface.self) { _ in
            return StoreInterfaceImpl()
        }
    }
}
