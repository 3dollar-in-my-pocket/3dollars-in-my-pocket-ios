import UIKit

import DesignSystem

import ReactorKit
import RxSwift

final class NicknameViewController: BaseViewController {
    private let nicknameView = NicknameView()
    private let viewModel: NicknameViewModel
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance(
        socialType: SocialType,
        accessToken: String,
        bookmarkFolderId: String? = nil
    ) -> NicknameViewController {
        return NicknameViewController(
            socialType: socialType,
            accessToken: accessToken,
            bookmarkFolderId: bookmarkFolderId
        )
    }
  
    init(socialType: SocialType, accessToken: String, bookmarkFolderId: String?) {
        self.viewModel = NicknameViewModel(
            socialType: socialType,
            accessToken: accessToken,
            bookmarkFolderId: bookmarkFolderId
        )
        
        super.init(nibName: nil, bundle: nil)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.nicknameView
    }
    
    override func bindViewModelInput() {
        nicknameView.nicknameField
            .controlPublisher(for: .editingChanged)
            .withUnretained(self)
            .compactMap { owner, _ in
                owner.nicknameView.nicknameField.text ?? ""
            }
            .subscribe(viewModel.input.inputNickname)
            .store(in: &cancellables)
        
        nicknameView.signupButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapSigninButton)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.isEnableSignupButton
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink(receiveValue: { owner, isEnabled in
                owner.nicknameView.setEnableSignupButton(isEnabled)
            })
            .store(in: &cancellables)
        
        viewModel.output.isHiddenWarningLabel
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, isHidden in
                owner.nicknameView.setHiddenWarning(isHidden: isHidden)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .presentPolicy:
                    print("💜present policy")
                    
                case .goToMain(let bookmarkFolderId):
                    print("💜go to main")
                    
                case .showErrorAlert(let error):
                    print("💜show error alert: \(error)")
                    
                case .showLoading(let isShow):
                    DesignSystem.LoadingManager.shared.showLoading(isShow: isShow)
                }
            }
            .store(in: &cancellables)
    }
    
    override func bindEvent() {
        nicknameView.backButton
            .controlPublisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)

//        self.nicknameReactor.showErrorAlertPublisher
//            .asDriver(onErrorJustReturn: BaseError.unknown)
//            .drive(onNext: { [weak self] error in
//                self?.coordinator?.showErrorAlert(error: error)
//            })
//            .disposed(by: self.eventDisposeBag)
    }
}

extension NicknameViewController: PolicyViewControllerDelegate {
    func onDismiss() {
//        self.nicknameReactor.action.onNext(.onSignupSuccess)
    }
}
