protocol WriteDetailCoordinator: AnyObject, BaseCoordinator {
    func pop()
    
    func presentFullMap()
    
    func presentCategorySelection()
}

extension WriteDetailCoordinator where Self: BaseViewController {
    func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    func presentFullMap() {
        
    }
    
    func presentCategorySelection() {
        
    }
}
