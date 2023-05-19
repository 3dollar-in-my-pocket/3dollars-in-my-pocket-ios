protocol MyVisitHistoryCoordinator: Coordinator, AnyObject {
    func goToStoreDetail(storeId: Int)
}

extension MyVisitHistoryCoordinator {
    func goToStoreDetail(storeId: Int) {
        let viewController = StoreDetailViewController.instance(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
}
