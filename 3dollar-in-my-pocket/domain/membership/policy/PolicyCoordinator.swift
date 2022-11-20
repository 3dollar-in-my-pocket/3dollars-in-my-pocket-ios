import UIKit

protocol PolicyCoordinator: BaseCoordinator, AnyObject {
    func pushPolicyPage()
    
    func pushMarketingPage()
    
    func dismiss(completion: (() -> ())?)
    
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
    
    func dismiss(completion: (() -> ())?) {
        DimManager.shared.hideDim()
        self.presenter.dismiss(animated: true) {
            completion?()
        }
    }
    
    func dismiss() {
        DimManager.shared.hideDim()
        self.presenter.dismiss(animated: true)
    }
}
