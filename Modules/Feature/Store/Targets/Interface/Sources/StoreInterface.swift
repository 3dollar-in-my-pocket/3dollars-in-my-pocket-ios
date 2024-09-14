import UIKit
import Combine

import Model

public protocol StoreInterface {
    func getStoreDetailViewController(storeId: Int) -> UIViewController

    func getBossStoreDetailViewController(storeId: String) -> UIViewController

    func getVisitViewController(
        storeId: Int,
        visitableStore: VisitableStore,
        onSuccessVisit: @escaping (() -> Void)
    ) -> UIViewController
    
    func getMapDetailViewController(location: LocationResponse, storeName: String) -> UIViewController
}
