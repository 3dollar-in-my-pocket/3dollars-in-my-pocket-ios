import UIKit

import ReactorKit
import RxSwift

final class NicknameViewController: BaseViewController, View, NicknameCoordinator {
    private let nicknameView = NicknameView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance(
        signinRequest: SigninRequest,
        bookmarkFolderId: String? = nil
    ) -> NicknameViewController {
        return NicknameViewController(
            signinRequest: signinRequest,
            bookmarkFolderId: bookmarkFolderId
        )
    }
  
    init(signinRequest: SigninRequest, bookmarkFolderId: String?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.nicknameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindEvent() {
//        self.nicknameView.backButton.rx.tap
//            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
//            .asDriver(onErrorJustReturn: ())
//            .drive(onNext: { [weak self] _ in
//                self?.coordinator?.presenter
//                    .navigationController?
//                    .popViewController(animated: true)
//            })
//            .disposed(by: self.eventDisposeBag)
//
//        self.nicknameView.rx.tapBackground
//            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
//            .asDriver(onErrorJustReturn: ())
//            .drive(onNext: { [weak self] _ in
//                self?.nicknameView.hideKeyboard()
//            })
//            .disposed(by: self.eventDisposeBag)
//
//        self.nicknameReactor.goToMainPublisher
//            .asDriver(onErrorJustReturn: nil)
//            .drive(onNext: { [weak self] bookmarkFolderId in
//                self?.coordinator?.goToMain(with: bookmarkFolderId)
//            })
//            .disposed(by: self.eventDisposeBag)
//
//        self.nicknameReactor.showLoadingPublisher
//            .asDriver(onErrorJustReturn: false)
//            .drive(onNext: { [weak self] isShow in
//                self?.coordinator?.showLoading(isShow: isShow)
//            })
//            .disposed(by: self.eventDisposeBag)
//
//        self.nicknameReactor.showErrorAlertPublisher
//            .asDriver(onErrorJustReturn: BaseError.unknown)
//            .drive(onNext: { [weak self] error in
//                self?.coordinator?.showErrorAlert(error: error)
//            })
//            .disposed(by: self.eventDisposeBag)
    }
    
    
    func bind(reactor: NicknameReactor) {
        // Bind Action
//        self.nicknameView.nicknameField.rx.text.orEmpty
//            .map { Reactor.Action.inputNickname($0) }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//
//        self.nicknameView.startButton1.rx.tap
//            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
//            .map { Reactor.Action.tapStartButton }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//
//        self.nicknameView.startButton2.rx.tap
//            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
//            .map { Reactor.Action.tapStartButton }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//
//        // Bind State
//        reactor.state
//            .map { $0.isStartButtonEnable }
//            .distinctUntilChanged()
//            .asDriver(onErrorJustReturn: false)
//            .drive(self.nicknameView.rx.isStartButtonEnable)
//            .disposed(by: self.disposeBag)
//
//        reactor.state
//            .map { $0.isErrorLabelHidden }
//            .distinctUntilChanged()
//            .asDriver(onErrorJustReturn: true)
//            .drive(self.nicknameView.rx.isErrorLabelHidden)
//            .disposed(by: self.disposeBag)
//
//        reactor.pulse(\.$presentPolicy)
//            .compactMap { $0 }
//            .asDriver(onErrorJustReturn: ())
//            .drive(onNext: { [weak self] _ in
//                self?.coordinator?.presentPolicy()
//            })
//            .disposed(by: self.disposeBag)
    }
}

extension NicknameViewController: PolicyViewControllerDelegate {
    func onDismiss() {
//        self.nicknameReactor.action.onNext(.onSignupSuccess)
    }
}
