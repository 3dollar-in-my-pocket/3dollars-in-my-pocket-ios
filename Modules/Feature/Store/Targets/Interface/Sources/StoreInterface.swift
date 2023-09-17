import UIKit

import Store

public protocol StoreInterface {
    func pushStoreDetail(storeId: Int) -> UIViewController
}

public final class StoreInterfaceImpl: StoreInterface {
    public init() { }
    
    public func pushStoreDetail(storeId: Int) -> UIViewController {
        return StoreDetailViewController.instance(storeId: storeId)
    }
}
