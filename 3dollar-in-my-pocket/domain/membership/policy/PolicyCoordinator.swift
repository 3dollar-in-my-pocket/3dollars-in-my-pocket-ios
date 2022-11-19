import UIKit

protocol PolicyCoordinator: BaseCoordinator, AnyObject {
    func pushPolicyPage()
    
    func pushMarketingPage()
    
    func dismissAndGoHome()
    
    func dismiss()
}

extension PolicyCoordinator {
    func pushPolicyPage() {
        guard let url = URL(string: Bundle.policyURL) else { return }
        
        UIApplication.shared.open(url)
    }
    
    func pushMarketingPage() {
        guard let url = URL(string: Bundle.marketingURL) else { return }
        
        UIApplication.shared.open(url)
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
