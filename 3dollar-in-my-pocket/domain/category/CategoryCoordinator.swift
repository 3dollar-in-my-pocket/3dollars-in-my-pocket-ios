protocol CategoryCoordinator: AnyObject, Coordinator {
    func pushCategoryList(category: StreetFoodStoreCategory)
}

extension CategoryCoordinator {
    func pushCategoryList(category: StreetFoodStoreCategory) {
        let viewController = CategoryListViewController.instance(category: category)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
}
