import Foundation
import UIKit

import Model
import StoreInterface
import DependencyInjection

public final class MockStoreModuleInterfaceImpl: StoreInterface {
    public func getStoreDetailViewController(storeId: Int) -> UIViewController {
        return UIViewController(nibName: nil, bundle: nil)
    }
    
    public func getBossStoreDetailViewController(storeId: String) -> UIViewController {
        return UIViewController(nibName: nil, bundle: nil)
    }
    
    public func getVisitViewController(storeId: Int, visitableStore: VisitableStore, onSuccessVisit: @escaping (() -> Void)) -> UIViewController {
        return UIViewController(nibName: nil, bundle: nil)
    }
    
    public func getMapDeetailViewController(location: Model.Location, storeName: String) -> UIViewController {
        return UIViewController(nibName: nil, bundle: nil)
    }
}

extension MockStoreModuleInterfaceImpl {
    public static func registerModuleInterface() {
        DIContainer.shared.container.register(StoreInterface.self) { _ in
            return MockStoreModuleInterfaceImpl()
        }
    }
}

