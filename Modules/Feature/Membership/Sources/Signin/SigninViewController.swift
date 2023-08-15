import UIKit

import Common
import DesignSystem

public final class SigninViewController: BaseViewController {
    private let signinView = SigninView()
    
    public static func instance() -> SigninViewController {
        return SigninViewController(nibName: nil, bundle: nil)
    }
    
    public override func loadView() {
        view = signinView
    }
}
