import UIKit

protocol MarkerPopupCoordinator: BaseCoordinator, AnyObject {
    func dismiss()
    
    func openURL(urlString: String)
}

extension MarkerPopupCoordinator where Self: MarkerPopupViewController {
    func dismiss() {
        DimManager.shared.hideDim()
        self.dismiss(animated: true)
    }
    
    func openURL(urlString: String) {
        DimManager.shared.hideDim()
        self.dismiss(animated: true) {
            guard let url = URL(string: urlString) else { return }
            
            UIApplication.shared.open(url)
        }
    }
}
