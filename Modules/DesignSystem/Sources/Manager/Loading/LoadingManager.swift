import UIKit

public class LoadingManager {
    public static let shared = LoadingManager()
    
    private let loadingView = LoadingView(frame: UIScreen.main.bounds)
    
    public func showLoading(isShow: Bool) {
        if isShow {
            showLoading()
        } else {
            hideLoading()
        }
    }
    
    private func showLoading() {
        if let sceneDelegate = UIApplication
            .shared
            .connectedScenes
            .first?.delegate as? UIWindowSceneDelegate {
            sceneDelegate.window??.addSubview(loadingView)
        }
        
        loadingView.startLoading()
    }
    
    private func hideLoading() {
        loadingView.stopLoading()
        loadingView.removeFromSuperview()
    }
}
