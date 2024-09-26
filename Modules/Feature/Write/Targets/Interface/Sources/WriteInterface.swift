import UIKit
import Combine

import Model

public protocol WriteInterface {
    func getWriteAddressViewController(onSuccessWrite: @escaping ((Int) -> ())) -> UIViewController
    
    func getWriteDetailViewController(
        location: LocationResponse,
        address: String,
        onSuccessWrite: @escaping ((Int) -> ())
    ) -> UIViewController
    
    func getEditDetailViewController(
        storeId: Int,
        storeDetailData: StoreDetailData,
        onSuccessEdit: @escaping ((StoreCreateResponse) -> ())
    ) -> UIViewController
}
