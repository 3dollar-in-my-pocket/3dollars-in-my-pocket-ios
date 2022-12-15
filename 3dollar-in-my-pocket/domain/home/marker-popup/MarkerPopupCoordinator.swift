protocol MarkerPopupCoordinator: BaseCoordinator, AnyObject {
    func dismiss()
}

extension MarkerPopupCoordinator where Self: MarkerPopupViewController {
    func dismiss() {
        DimManager.shared.hideDim()
        self.dismiss(animated: true)
    }
}
