import Foundation

protocol RegisteredStoreCoordinator: AnyObject, Coordinator {
    func goToStoreDetail(storeId: Int)
}

extension RegisteredStoreCoordinator {
    func goToStoreDetail(storeId: Int) {
        let viewController = Environment.storeInterface.getStoreDetailViewController(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
}
