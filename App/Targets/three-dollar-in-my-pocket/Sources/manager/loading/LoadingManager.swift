import UIKit

protocol LoadingManagerProtocol: AnyObject {
    func showLoading(isShow: Bool)
}

final class LoadingManager: LoadingManagerProtocol {
    static let shared = LoadingManager()
    
    private let loadingView = LoadingView(frame: UIScreen.main.bounds)
    
    func showLoading(isShow: Bool) {
        if isShow {
            self.showLoading()
        } else {
            self.hideLoading()
        }
    }
    
    private func showLoading() {
        if let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? SceneDelegate {
            sceneDelegate.window?.addSubview(self.loadingView)
        }
        
        self.loadingView.startLoading()
    }
    
    private func hideLoading() {
        self.loadingView.stopLoading()
        self.loadingView.removeFromSuperview()
    }
}
