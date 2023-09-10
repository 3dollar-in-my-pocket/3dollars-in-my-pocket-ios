import UIKit

public struct UIUtils {
    public static var windowBounds: CGRect {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .zero }
        
        return window.screen.bounds
    }
}
