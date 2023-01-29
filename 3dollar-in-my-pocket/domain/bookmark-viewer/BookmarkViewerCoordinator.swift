protocol BookmarkViewerCoordinator: BaseCoordinator, AnyObject {
    func pushStoreDetail(storeId: String)
    
    func pushFoodTruckDetail(storeId: String)
}

extension BookmarkViewerCoordinator {
    func pushStoreDetail(storeId: String) {
        guard let storeId = Int(storeId) else { return }
        let viewController = StoreDetailViewController.instance(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func pushFoodTruckDetail(storeId: String) {
        let viewController = BossStoreDetailViewController.instance(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
}
