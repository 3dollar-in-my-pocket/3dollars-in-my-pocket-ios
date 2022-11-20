import UIKit

protocol SettingCoordinator: BaseCoordinator, AnyObject {
    func pushEditNickname(nickname: String)
    
    func goToSignin()
    
    func pushPrivacy()
    
    func pushPolicyPage()
    
    func pushQuestion()
    
    func showLogoutAlert()
    
    func showSignoutAlert()
}

extension SettingCoordinator where Self: SettingViewController {
    func pushEditNickname(nickname: String) {
        let viewController = RenameVC.instance(currentName: nickname)
        
        self.presenter.navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
    
    func goToSignin() {
        if let sceneDelegate =
            UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.goToSignIn()
        }
    }
    
    func pushPrivacy() {
        let viewController = PrivacyVC.instance()
        
        self.presenter.navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
    
    func pushPolicyPage() {
        let viewController = PrivacyVC.instance()
        
        self.presenter.navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
    
    func pushQuestion() {
        let viewController = QuestionVC.instance()
        
        self.presenter.navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
    
    func showLogoutAlert() {
        AlertUtils.showWithCancel(
            controller: self,
            title: R.string.localization.setting_logout_title()
        ) {
            self.reactor?.action.onNext(.logout)
        }
    }
    
    func showSignoutAlert() {
        AlertUtils.showWithCancel(
            controller: self,
            title: R.string.localization.setting_withdrawal(),
            message: R.string.localization.setting_signout_message()
        ) {
            self.reactor?.action.onNext(.signout)
        }
    }
}
