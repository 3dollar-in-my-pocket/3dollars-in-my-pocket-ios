import UIKit
import Combine

import DependencyInjection
import WriteInterface
import Model

public final class WriteInterfaceImpl: WriteInterface {
    public func getWriteAddressViewController(
        config: WriteAddressViewModelConfig?,
        onSuccessWrite: @escaping ((Int) -> ())
    ) -> UIViewController {
        let viewModel = WriteAddressViewModel()
        let viewController = WriteAddressViewController(viewModel: viewModel)
        
        viewController.onSuccessWrite = { storeId in
            onSuccessWrite(storeId)
        }
        
        let navigationController = WriteNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .overCurrentContext
        return navigationController
    }
    
    public func getWriteDetailViewController(
        location: LocationResponse,
        address: String,
        onSuccessWrite: @escaping ((Int) -> ())
    ) -> UIViewController {
        let config = WriteDetailViewModel.WriteConfig(location: location, address: address)
        let viewModel = WriteDetailViewModel(config: config)
        let viewController = WriteDetailViewController(viewModel: viewModel)
        
        viewController.onSuccessWrite = { storeId in
            onSuccessWrite(storeId)
        }
        
        return viewController
    }
    
    public func getEditDetailViewController(
        storeId: Int,
        storeDetailData: StoreDetailData,
        onSuccessEdit: @escaping ((UserStoreCreateResponse) -> ())
    ) -> UIViewController {
        let config = WriteDetailViewModel.EditConfig(storeId: storeId, storeDetailData: storeDetailData)
        let viewModel = WriteDetailViewModel(config: config)
        let viewController = WriteDetailViewController(viewModel: viewModel)
        
        viewController.onSuccessEdit = { storeCreateResponse in
            onSuccessEdit(storeCreateResponse)
        }
        
        return viewController
    }
}

public extension WriteInterfaceImpl {
    static func registerStoreInterface() {
        DIContainer.shared.container.register(WriteInterface.self) { _ in
            return WriteInterfaceImpl()
        }
    }
}
