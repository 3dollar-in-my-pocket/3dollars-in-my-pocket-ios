import UIKit
import Combine
import CoreLocation

import Model

public protocol WriteInterface {
    func getWriteAddressViewController(
        config: WriteAddressViewModelConfig?,
        onSuccessWrite: @escaping ((String) -> ())
    ) -> UIViewController
    
    func getEditDetailViewController(
        storeId: Int,
        storeDetailData: StoreDetailData,
        onSuccessEdit: @escaping ((UserStoreCreateResponse) -> ())
    ) -> UIViewController
}


public struct WriteAddressViewModelConfig {
    public let type: WriteAddressType
    public let address: String
    public let cameraPosition: CLLocation
    
    public init(type: WriteAddressType, address: String, cameraPosition: CLLocation) {
        self.type = type
        self.address = address
        self.cameraPosition = cameraPosition
    }
}
