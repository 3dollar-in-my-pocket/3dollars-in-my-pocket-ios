import UIKit

import ReactorKit
import RxSwift

protocol BookmarkSigninDialogViewControllerDelegate: AnyObject {
    func onSigninSuccess()
    
    func whenAccountNotExisted(signinRequest: SigninRequest)
}

final class BookmarkSigninDialogViewController
: BaseViewController, View, BookmarkSigninDialogCoordinator {
    weak var delegate: BookmarkSigninDialogViewControllerDelegate?
    private let bookmarkSigninDialogView = BookmarkSigninDialogView()
    private let bookmarkSigninDialogReactor = BookmarkSigninDialogReactor(
        userDefaults: UserDefaultsUtil(),
        userService: UserService(),
        deviceService: DeviceService(),
        kakaoManager: KakaoSigninManager(),
        appleManager: AppleSigninManager()
    )
    private weak var coordinator: BookmarkSigninDialogCoordinator?
    
    static func instance() -> BookmarkSigninDialogViewController {
        return BookmarkSigninDialogViewController(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = self.bookmarkSigninDialogView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
        self.coordinator = self
        self.reactor = self.bookmarkSigninDialogReactor
    }
    
    override func bindEvent() {
        self.bookmarkSigninDialogView.rx.tapBackground
            .asDriver()
            .throttle(.milliseconds(300))
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.bookmarkSigninDialogView.closeButton.rx.tap
            .asDriver()
            .throttle(.milliseconds(300))
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: BookmarkSigninDialogReactor) {
        // Bind Action
        self.bookmarkSigninDialogView.kakaoButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapKakaoButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.bookmarkSigninDialogView.appleButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapAppleButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.pulse(\.$goToMain)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismissAndGoToMain()
            })
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$pushNickname)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: SigninRequest(socialType: .apple, token: ""))
            .drive(onNext: { [weak self] signinRequest in
                self?.coordinator?.dismissAndPushNickname(signinRequest: signinRequest)
            })
            .disposed(by: self.disposeBag)
    }
}
