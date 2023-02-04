protocol BookmarkSigninDialogCoordinator: BaseCoordinator, AnyObject {
    func dismiss()
}

extension BookmarkSigninDialogCoordinator {
    func dismiss() {
        DimManager.shared.hideDim()
        self.presenter.dismiss(animated: true)
    }
}
