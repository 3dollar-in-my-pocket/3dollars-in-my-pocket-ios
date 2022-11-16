import UIKit

import Base
import ReactorKit
import RxSwift

final class SigninViewController: BaseViewController, View {
    private let signInView = SignInView()
    private let signinReactor = SigninReactor(
        userDefaults: UserDefaultsUtil(),
        userService: UserService(),
        kakaoManager: KakaoSigninManager(),
        appleManager: AppleSigninManager()
    )
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> UINavigationController {
        let controller = SigninViewController(nibName: nil, bundle: nil)
        
        return UINavigationController(rootViewController: controller)
    }
    
    override func loadView() {
        self.view = self.signInView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signInView.startFadeIn()
        self.reactor = self.signinReactor
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    func bind(reactor: SigninReactor) {
        // Bind Action
        self.signInView.kakaoButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapKakaoButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.signInView.appleButton.rx
          .controlEvent(.touchUpInside)
          .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
          .map { _ in Reactor.Action.tapAppleButton }
          .bind(to: reactor.action)
          .disposed(by: self.disposeBag)
        
        self.signInView.signinWithoutIdButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapWithoutSignin }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.pulse(\.$goToMain)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pushNickname)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] signinRequest in
                
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$showErrorAlert)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] error in
                
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$showLoading)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] isShow in
                
            })
            .disposed(by: self.disposeBag)
    }
}
