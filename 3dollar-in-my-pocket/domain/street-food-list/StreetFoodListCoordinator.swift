import Foundation

protocol StreetFoodListCoordinator: Coordinator, AnyObject {
    func pushStoreDetail(storeId: Int)
}

extension StreetFoodListCoordinator where Self: BaseVC {
    func pushStoreDetail(storeId: Int) {
        let viewController = StoreDetailViewController.instance(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
}
