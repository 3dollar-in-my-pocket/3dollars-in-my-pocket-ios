import UIKit

import Common
import DesignSystem

public final class SplashViewController: BaseViewController {
    private let splashView = SplashView()
    
    public static func instacne() -> SplashViewController {
        return SplashViewController(nibName: nil, bundle: nil)
    }
    
    public override func loadView() {
        view = splashView
    }
}
