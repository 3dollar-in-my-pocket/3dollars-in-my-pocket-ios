import UIKit

import Base

protocol BaseCoordinator {
    var presenter: BaseViewController { get }
    
    func showErrorAlert(error: Error)
    func openURL(url: String)
    func showLoading(isShow: Bool)
    func showToast(message: String)
}

extension BaseCoordinator where Self: BaseViewController {
    var presenter: BaseViewController {
        return self
    }
    
    func showErrorAlert(error: Error) {
        self.presenter.showErrorAlert(error: error)
    }
    
    func openURL(url: String) {
        guard let url = URL(string: url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func showLoading(isShow: Bool) {
        LoadingManager.shared.showLoading(isShow: isShow)
    }
    
    func showToast(message: String) {
        ToastManager.shared.show(message: message)
    }
}
