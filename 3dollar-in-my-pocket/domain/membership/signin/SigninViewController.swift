import UIKit

import Base
import ReactorKit
import RxSwift

final class SigninViewController: BaseViewController, View, SigninCoordinator {
    private let signinView = SigninView()
    private let signinReactor = SigninReactor(
        userDefaults: UserDefaultsUtil(),
        userService: UserService(),
        kakaoManager: KakaoSigninManager(),
        appleManager: AppleSigninManager()
    )
    private weak var coordinator: SigninCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> UINavigationController {
        let controller = SigninViewController(nibName: nil, bundle: nil)
        
        return UINavigationController(rootViewController: controller)
    }
    
    override func loadView() {
        self.view = self.signinView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signinView.startFadeIn()
        self.reactor = self.signinReactor
        self.coordinator = self
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func bindEvent() {
        self.signinView.signinWithoutIdButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.showWarningAlert()
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: SigninReactor) {
        // Bind Action
        self.signinView.kakaoButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapKakaoButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.signinView.appleButton.rx
          .controlEvent(.touchUpInside)
          .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
          .map { _ in Reactor.Action.tapAppleButton }
          .bind(to: reactor.action)
          .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.pulse(\.$goToMain)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.goToMain()
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pushNickname)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: SigninRequest(socialType: .unknown, token: ""))
            .drive(onNext: { [weak self] signinRequest in
                self?.coordinator?.pushNickname(signinRequest: signinRequest)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$showErrorAlert)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: BaseError.unknown)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$showLoading)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.disposeBag)
    }
}
