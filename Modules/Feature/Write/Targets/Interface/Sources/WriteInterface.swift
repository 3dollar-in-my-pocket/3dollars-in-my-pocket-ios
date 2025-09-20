import UIKit
import Combine
import CoreLocation

import Model

public protocol WriteInterface {
    func getWriteAddressViewController(
        config: WriteAddressViewModelConfig,
        onSuccessWrite: @escaping ((String) -> ())
    ) -> UIViewController
    
    func createEditStoreViewModel(config: EditStoreViewModelConfig) -> EditStoreViewModelInterface
    
    func createEditStoreViewController(viewModel: EditStoreViewModelInterface) -> UIViewController
}
