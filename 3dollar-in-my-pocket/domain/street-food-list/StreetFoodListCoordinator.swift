import Foundation

protocol StreetFoodListCoordinator: BaseCoordinator, AnyObject {
    func presentCategoryFilter()
    
    func pushStoreDetail(storeId: Int)
    
    func presentWriteAddress()
}

extension StreetFoodListCoordinator where Self: StreetFoodListViewController {
    func presentCategoryFilter() {
        let viewController = CategoryViewController.instance()
        
        self.presenter.present(viewController, animated: true)
    }
    
    func pushStoreDetail(storeId: Int) {
        let viewController = StoreDetailViewController.instance(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func presentWriteAddress() {
        let viewController = WriteAddressViewController.instance(delegate: self)
        
        self.tabBarController?.present(viewController, animated: true)
    }
}
