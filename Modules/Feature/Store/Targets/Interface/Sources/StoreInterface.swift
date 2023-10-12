import UIKit
import Combine

import Model

public protocol StoreInterface {
    func getStoreDetailViewController(storeId: Int) -> UIViewController
    
    func getVisitViewController(
        storeId: Int,
        visitableStore: VisitableStore,
        onSuccessVisit: @escaping (() -> Void)
    ) -> UIViewController
    
    func getMapDeetailViewController(location: Location, storeName: String) -> UIViewController
}
