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
    }
    
    override func bindViewModel() {
        Observable.just(()).delay(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe { [weak self] in
                if let _ = UserDefaultsUtil.getUserToken() {
                    self?.goToMain()
                } else {
                    self?.goToSignIn()
                }
        }.disposed(by: disposeBag)
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
