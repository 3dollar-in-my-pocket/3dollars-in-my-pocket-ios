protocol FoodTruckListCoordinator: BaseCoordinator, AnyObject {
    func presentCategoryFilter()
    
    func pushBossStoreDetail(storeId: String)
}

extension FoodTruckListCoordinator where Self: FoodTruckListViewController {
    func presentCategoryFilter() {
        let viewController = CategoryFilterViewController.instance(storeType: .foodTruck)
        
        self.tabBarController?.present(viewController, animated: true)
    }
    
    func pushBossStoreDetail(storeId: String) {
        let viewController = BossStoreDetailViewController.instance(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
}
