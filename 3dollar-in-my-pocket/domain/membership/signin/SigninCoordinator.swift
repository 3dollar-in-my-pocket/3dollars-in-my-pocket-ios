import UIKit

protocol SigninCoordinator: BaseCoordinator, AnyObject {
    func goToMain()
    
    func pushNickname(signinRequest: SigninRequest)
}

extension SigninCoordinator {
    func goToMain() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.goToMain()
        }
    }
    
    func pushNickname(signinRequest: SigninRequest) {
        let nicknameVC = NicknameViewController.instance(signinRequest: signinRequest)
        
        self.presenter.navigationController?.pushViewController(nicknameVC, animated: true)
    }
}
