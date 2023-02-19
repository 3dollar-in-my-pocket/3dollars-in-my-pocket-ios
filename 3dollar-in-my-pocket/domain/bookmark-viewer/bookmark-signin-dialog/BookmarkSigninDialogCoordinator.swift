protocol BookmarkSigninDialogCoordinator: BaseCoordinator, AnyObject {
    func dismiss()
    
    func dismissAndGoToMain()
    
    func dismissAndPushNickname(signinRequest: SigninRequest)
}

extension BookmarkSigninDialogCoordinator where Self: BookmarkSigninDialogViewController {
    func dismiss() {
        DimManager.shared.hideDim()
        self.presenter.dismiss(animated: true)
    }
    
    func dismissAndGoToMain() {
        DimManager.shared.hideDim()
        self.presenter.dismiss(animated: true) {
            self.delegate?.onSigninSuccess()
        }
    }
    
    func dismissAndPushNickname(signinRequest: SigninRequest) {
        DimManager.shared.hideDim()
        self.presenter.dismiss(animated: true) {
            self.delegate?.whenAccountNotExisted(signinRequest: signinRequest)
        }
    }
}
