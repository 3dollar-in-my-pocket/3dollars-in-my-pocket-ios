import UIKit

protocol SigninCoordinator: BaseCoordinator, AnyObject {
    func goToMain()
    
    func pushNickname(signinRequest: SigninRequest)
    
    func showWarningAlert()
}

extension SigninCoordinator where Self: SigninViewController {
    func goToMain() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.goToMain()
        }
    }
    
    func pushNickname(signinRequest: SigninRequest) {
        let nicknameVC = NicknameViewController.instance(signinRequest: signinRequest)
        
        self.presenter.navigationController?.pushViewController(nicknameVC, animated: true)
    }
    
    func showWarningAlert() {
        AlertUtils.showWithCancel(
            controller: self,
            message: "sign_in_anonymous_warning".localized
        ) {
//            self.reactor?.action.onNext(.tapWithoutSignin)
        }
    }
}
