import Foundation

protocol StreetFoodListCoordinator: BaseCoordinator, AnyObject {
    func pushStoreDetail(storeId: Int)
}

extension StreetFoodListCoordinator where Self: StreetFoodListViewController {
    func pushStoreDetail(storeId: Int) {
        let viewController = StoreDetailViewController.instance(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
}
