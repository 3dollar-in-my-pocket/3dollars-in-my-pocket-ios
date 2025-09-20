import UIKit
import Combine

import DependencyInjection
import WriteInterface
import Model

public final class WriteInterfaceImpl: WriteInterface {
    public func getWriteAddressViewController(
        config: WriteAddressViewModelConfig,
        onSuccessWrite: @escaping ((String) -> ())
    ) -> UIViewController {
        let viewModel = WriteAddressViewModel(config: config)
        let navigationViewModel = WriteNavigationViewModel()
        
        viewModel.output.finishWriteAddress
            .subscribe(navigationViewModel.input.finishWriteAddress)
            .store(in: &viewModel.cancellables)
        let viewController = WriteAddressViewController(viewModel: viewModel)
        let navigationController = WriteNavigationController(rootViewController: viewController, viewModel: navigationViewModel)
        
        navigationController.onSuccessWrite = { storeId in
            onSuccessWrite(storeId)
        }
        navigationController.modalPresentationStyle = .overCurrentContext
        return navigationController
    }
    
    public func createEditStoreViewModel(config: EditStoreViewModelConfig) -> EditStoreViewModelInterface {
        return EditStoreViewModel(config: config)
    }
    
    public func createEditStoreViewController(viewModel: EditStoreViewModelInterface) -> UIViewController {
        guard let viewModel = viewModel as? EditStoreViewModel else {
            return UIViewController(nibName: nil, bundle: nil)
        }
        
        return EditStoreViewController(viewModel: viewModel)
    }
}

public extension WriteInterfaceImpl {
    static func registerStoreInterface() {
        DIContainer.shared.container.register(WriteInterface.self) { _ in
            return WriteInterfaceImpl()
        }
    }
}
