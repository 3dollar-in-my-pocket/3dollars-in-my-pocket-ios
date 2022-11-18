import UIKit

import Base

final class PolicyViewController: BaseViewController {
    private let policyView = PolicyView()
    
    static func instance() -> PolicyViewController {
        return PolicyViewController(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = self.policyView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
