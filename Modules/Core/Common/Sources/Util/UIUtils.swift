import UIKit

public struct UIUtils {
    public static var windowBounds: CGRect {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .zero }
        
        return window.screen.bounds
    }
    
    public static var bottomSafeAreaInset: CGFloat {
        if #available(iOS 15.0, *) {
            let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
            return window?.keyWindow?.safeAreaInsets.bottom ?? .zero
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? .zero
        }
    }
    
    public static func getTopViewController(_ viewController: UIViewController) -> UIViewController {
        var presentingViewController = viewController
        while let presentedViewController = presentingViewController.presentedViewController {
            presentingViewController = presentedViewController
        }
        return presentingViewController
    }
}
