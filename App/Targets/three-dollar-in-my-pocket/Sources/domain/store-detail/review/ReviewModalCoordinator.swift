protocol ReviewModalCoordinator: BaseCoordinator, AnyObject {
    func dismiss()
}

extension ReviewModalCoordinator where Self: ReviewModalViewController {
    func dismiss() {
        DimManager.shared.hideDim()
        self.dismiss(animated: true)
    }
}
