import UIKit

struct LoadingViewUtil {
    
    static var loadingView = LoadingView(frame: UIScreen.main.bounds)
    
    static func addLoadingView() {
        let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
        
        keyWindow?.addSubview(LoadingViewUtil.loadingView)
    }
    
    static func removeLoadingView() {
        LoadingViewUtil.loadingView.removeFromSuperview()
    }
}
