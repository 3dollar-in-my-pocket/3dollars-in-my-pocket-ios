protocol SigninAnonymousCoordinator: BaseCoordinator, AnyObject {
    func showAlreadyExist(signinRequest: SigninRequest)
}

extension SigninAnonymousCoordinator where Self: SigninAnonymousViewController {
    func showAlreadyExist(signinRequest: SigninRequest) {
        AlertUtils.showWithCancel(
            controller: self,
            message: "sign_in_with_existed_account".localized
        ) {
            self.reactor?.action.onNext(.signin(signinRequest: signinRequest))
        }
    }
}
