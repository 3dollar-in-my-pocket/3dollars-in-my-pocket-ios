protocol CategoryFilterCoordinator: AnyObject, BaseCoordinator {
    func dismiss()
}

extension CategoryFilterCoordinator where Self: CategoryFilterViewController {
    func dismiss() {
        DimManager.shared.hideDim()
        self.dismiss(animated: true, completion: nil)
    }
}
