protocol CategorySelectionCoordinator: AnyObject, BaseCoordinator {
    func handleRoute(route: CategorySelectionViewModel.Route)
}

extension CategorySelectionCoordinator where Self: CategorySelectionViewController {
    func handleRoute(route: CategorySelectionViewModel.Route) {
        switch route {
        case .dismissWithCategories(let selectedCategories):
            delegate?.onSelectCategories(categories: selectedCategories)
            dismiss()
        }
    }
}
