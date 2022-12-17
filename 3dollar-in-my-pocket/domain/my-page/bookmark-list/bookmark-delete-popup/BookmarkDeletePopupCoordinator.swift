protocol BookmarkDeletePopupCoordinator: AnyObject, BaseCoordinator {
    func dismiss()
}

extension BookmarkDeletePopupCoordinator where Self: BookmarkDeletePopupViewController {
    func dismiss() {
        DimManager.shared.hideDim()
        self.dismiss(animated: true)
    }
}
