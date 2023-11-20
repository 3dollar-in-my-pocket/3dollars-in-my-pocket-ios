protocol MyVisitHistoryCoordinator: Coordinator, AnyObject {
    func goToStoreDetail(storeId: Int)
}

extension MyVisitHistoryCoordinator {
    func goToStoreDetail(storeId: Int) {
        let viewController = Environment.storeInterface.getStoreDetailViewController(storeId: storeId)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
}
