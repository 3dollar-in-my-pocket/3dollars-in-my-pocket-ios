protocol SigninAnonymousCoordinator: BaseCoordinator, AnyObject {
    func showAlreadyExist(signinRequest: SigninRequest)
}

extension SigninAnonymousCoordinator where Self: SigninAnonymousViewController {
    func showAlreadyExist(signinRequest: SigninRequest) {
        AlertUtils.showWithCancel(
            controller: self,
            message: "이미 가입한 계정이 있습니다.\n해당 계정으로 로그인 하시겠습니까?\n비로그인으로 활동한 이력들은 유지되지 않습니다"
        ) {
            self.reactor?.action.onNext(.signin(signinRequest: signinRequest))
        }
    }
}
