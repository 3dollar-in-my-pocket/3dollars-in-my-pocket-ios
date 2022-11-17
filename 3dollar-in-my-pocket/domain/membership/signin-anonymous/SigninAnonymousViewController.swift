import UIKit

import Base
import ReactorKit

final class SigninAnonymousViewController: BaseViewController, View, SigninAnonymousCoordinator {
    private let signinAnonymousView = SigninAnonymousView()
    private let signinAnonymousReactor = SigninAnonymousReactor(
        userDefaults: UserDefaultsUtil(),
        userService: UserService(),
        kakaoManager: KakaoSigninManager(),
        appleManager: AppleSigninManager()
    )
    private weak var coordinator: SigninAnonymousCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
        
        self.reactor = self.signinAnonymousReactor
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.signinAnonymousView.closeButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.presenter.dismiss(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: SigninAnonymousReactor) {
        // Bind Action
        self.signinAnonymousView.kakaoButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapKakaoButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.signinAnonymousView.appleButton.rx.controlEvent(.touchUpInside)
            .map { _ in () }
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapAppleButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.pulse(\.$dismiss)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.presenter.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$showErrorAlert)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
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
