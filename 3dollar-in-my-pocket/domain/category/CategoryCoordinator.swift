protocol CategoryCoordinator: AnyObject, Coordinator {
    func pushCategoryList(category: StoreCategory)
}

extension CategoryCoordinator {
    func pushCategoryList(category: StoreCategory) {
        let viewController = CategoryListVC.instance(category: category)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
}
