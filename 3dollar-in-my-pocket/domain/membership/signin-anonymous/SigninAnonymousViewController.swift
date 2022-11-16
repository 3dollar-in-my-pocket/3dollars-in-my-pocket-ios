import UIKit

import Base
import ReactorKit

final class SigninAnonymousViewController: BaseViewController {
    private let signinAnonymousView = SigninAnonymousView()
    
    static func instance() -> SigninAnonymousViewController {
        return SigninAnonymousViewController(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = self.signinAnonymousView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
