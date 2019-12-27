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
    
    override func bindViewModel() {
        nicknameView.button.rx.tap.bind {
            self.goToMain()
        }.disposed(by: disposeBag)
    }
    
    private func goToMain() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.goToMain()
        }
    }
}
