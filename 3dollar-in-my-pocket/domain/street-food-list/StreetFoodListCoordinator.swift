import Foundation

protocol StreetFoodListCoordinator: BaseCoordinator, AnyObject {
    func presentCategoryFilter()
    
    func pushStoreDetail(storeId: Int)
}

extension StreetFoodListCoordinator where Self: StreetFoodListViewController {
    func presentCategoryFilter() {
        let viewController = CategoryFilterViewController.instance(storeType: .streetFood)
        
        self.tabBarController?.present(viewController, animated: true)
    }
    
    func pushStoreDetail(storeId: Int) {
        let viewController = StoreDetailViewController.instance(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
}
