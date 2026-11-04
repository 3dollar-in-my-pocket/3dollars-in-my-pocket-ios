import UIKit

public class LoadingManager {
    public static let shared = LoadingManager()
    
    private let loadingView: LoadingView = {
        let loadingView = LoadingView(frame: .zero)
        loadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return loadingView
    }()
    
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
            .first?.delegate as? UIWindowSceneDelegate,
           let window = sceneDelegate.window ?? nil {
            loadingView.frame = window.bounds
            window.addSubview(loadingView)
        }
        
        loadingView.startLoading()
    }
    
    private func hideLoading() {
        loadingView.stopLoading()
        loadingView.removeFromSuperview()
    }
}
