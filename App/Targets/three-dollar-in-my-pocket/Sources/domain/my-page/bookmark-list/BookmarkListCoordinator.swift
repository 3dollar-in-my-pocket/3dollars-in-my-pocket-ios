import UIKit

protocol BookmarkListCoordinator: BaseCoordinator, AnyObject {
    func pushStoreDetail(storeId: String)
    
    func pushFoodTruckDetail(storeId: String)
    
    func showDeleteAllPopup()
    
    func pushEditBookmarkFolder(bookmarkFolder: BookmarkFolder)
    
    func presentSharePannel(url: String)
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
        let viewController = BookmarkEditViewController.instance(bookmarkFolder: bookmarkFolder)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func presentSharePannel(url: String) {
        let viewController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        viewController.popoverPresentationController?.sourceView = self.presenter.view
        self.presenter.present(viewController, animated: true, completion: nil)
    }
}
