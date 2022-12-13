protocol BookmarkListCoordinator: BaseCoordinator, AnyObject {
    func pushStoreDetail(storeId: String)
    
    func pushFoodTruckDetail(storeId: String)
    
    func showDeleteAllPopup()
    
    func pushEditBookmarkFolder(bookmarkFolder: BookmarkFolder)
}

extension BookmarkListCoordinator {
    func pushStoreDetail(storeId: String) {
        guard let storeId = Int(storeId) else { return }
        let viewController = StoreDetailViewController.instance(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func pushFoodTruckDetail(storeId: String) {
        let viewController = BossStoreDetailViewController.instance(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showDeleteAllPopup() {
        let viewController = BookmarkDeletePopupViewController.instance()
        
        viewController.delegate = self as? BookmarkDeletePopupDelegate
        self.presenter.present(viewController, animated: true)
    }
    
    func pushEditBookmarkFolder(bookmarkFolder: BookmarkFolder) {
        let viewController = BookmarkEditViewController.instance(bookamrkFolder: bookmarkFolder)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
}
