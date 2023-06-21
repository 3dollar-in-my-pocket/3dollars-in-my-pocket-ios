protocol WriteDetailCoordinator: AnyObject, BaseCoordinator {
    func pop()
    
    func presentFullMap()
    
    func presentCategorySelection(selectedCategories: [PlatformStoreCategory])
}

extension WriteDetailCoordinator where Self: BaseViewController {
    func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    func presentFullMap() {
        
    }
    
    func presentCategorySelection(selectedCategories: [PlatformStoreCategory]) {
        let viewController = CategorySelectionViewController.instance(selectedCategories: selectedCategories)
        viewController.delegate = self as? CategorySelectionDelegate
        
        presenter.present(viewController, animated: true)
    }
}
