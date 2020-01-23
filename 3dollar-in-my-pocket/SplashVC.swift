import UIKit
import RxSwift

class SplashVC: BaseVC {
    
    private lazy var splashView = SplashView(frame: self.view.frame)
    
    
    static func instance() -> SplashVC {
        return SplashVC.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = splashView
        
        splashView.lottie.play { [weak self] (isFinish) in
            if isFinish {
                if let _ = UserDefaultsUtil.getUserToken() {
                    self?.goToMain()
                } else {
                    self?.goToSignIn()
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func goToMain() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.goToMain()
        }
    }
    
    private func goToSignIn() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.goToSignIn()
        }
    }
}
