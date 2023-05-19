import UIKit

protocol Coordinator {
    var presenter: BaseVC { get }
    
    func popup()
    func dismiss()
    func showRootDim(isShow: Bool)
    func showErrorAlert(error: Error)
    func openURL(url: String)
}

extension Coordinator where Self: BaseVC {
    
    var presenter: BaseVC {
        return self
    }
    
    func popup() {
        self.presenter.navigationController?.popViewController(animated: true)
    }
    
    func dismiss() {
        self.presenter.dismiss(animated: true, completion: nil)
    }
    
    func showLoading(isShow: Bool) {
        
    }
    
    func showRootDim(isShow: Bool) {
        self.presenter.showRootDim(isShow: isShow)
    }
    
    func showErrorAlert(error: Error) {
        self.presenter.showErrorAlert(error: error)
    }
    
    func openURL(url: String) {
        guard let url = URL(string: url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
