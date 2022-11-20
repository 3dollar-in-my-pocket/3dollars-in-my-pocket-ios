import UIKit

protocol PolicyCoordinator: BaseCoordinator, AnyObject {
    func pushPolicyPage()
    
    func pushMarketingPage()
    
    func dismissAndGoHome()
    
    func dismiss()
}

extension PolicyCoordinator {
    func pushPolicyPage() {
        let viewController = WebViewController.instance(webviewType: .policy)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func pushMarketingPage() {
        let viewController = WebViewController.instance(webviewType: .marketing)
        
        self.presenter.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func dismissAndGoHome() {
        DimManager.shared.hideDim()
        self.presenter.dismiss(animated: true) {
            self.goToMain()
        }
    }
    
    func dismiss() {
        DimManager.shared.hideDim()
        self.presenter.dismiss(animated: true)
    }
    
    private func goToMain() {
        if let sceneDelegate
            = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.goToMain()
        }
    }
}
