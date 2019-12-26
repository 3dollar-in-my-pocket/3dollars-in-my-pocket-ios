import UIKit

class NicknameVC: BaseVC {
    
    private lazy var nicknameView = NicknameView(frame: self.view.frame)
    
    
    static func instance() -> NicknameVC {
        return NicknameVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = nicknameView
    }
}
