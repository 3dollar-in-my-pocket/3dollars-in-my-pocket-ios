import Foundation

protocol StreetFoodListCoordinator: BaseCoordinator, AnyObject {
    func pushStoreDetail(storeId: Int)
    
    func presentWriteAddress()
}

extension StreetFoodListCoordinator where Self: StreetFoodListViewController {
    func pushStoreDetail(storeId: Int) {
        let viewController = StoreDetailViewController.instance(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func presentWriteAddress() {
        let viewController = WriteAddressViewController.instance(delegate: self)
        
        self.tabBarController?.present(viewController, animated: true)
    }
}
