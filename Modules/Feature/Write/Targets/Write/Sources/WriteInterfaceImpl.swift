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
        let navigationViewModel = WriteNavigationViewModel()
        
        viewModel.output.finishWriteAddress
            .subscribe(navigationViewModel.input.finishWriteAddress)
            .store(in: &viewModel.cancellables)
        
        let viewController = WriteAddressViewController(viewModel: viewModel)
        viewController.onSuccessWrite = { storeId in
            onSuccessWrite(storeId)
        }
        
        let navigationController = WriteNavigationController(rootViewController: viewController, viewModel: navigationViewModel)
        navigationController.modalPresentationStyle = .overCurrentContext
        return navigationController
    }
    
    public func getEditDetailViewController(
        storeId: Int,
        storeDetailData: StoreDetailData,
        onSuccessEdit: @escaping ((UserStoreCreateResponse) -> ())
    ) -> UIViewController {
//        let config = WriteDetailViewModel.EditConfig(storeId: storeId, storeDetailData: storeDetailData)
//        let viewModel = WriteDetailViewModel(config: config)
//        let viewController = WriteDetailViewController(viewModel: viewModel)
//        
//        viewController.onSuccessEdit = { storeCreateResponse in
//            onSuccessEdit(storeCreateResponse)
//        }
//        
//        return viewController
        return UIViewController(nibName: nil, bundle: nil)
    }
}

public extension WriteInterfaceImpl {
    static func registerStoreInterface() {
        DIContainer.shared.container.register(WriteInterface.self) { _ in
            return WriteInterfaceImpl()
        }
    }
}
