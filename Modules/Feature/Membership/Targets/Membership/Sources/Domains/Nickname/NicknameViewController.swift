import UIKit

import Common
import DesignSystem
import Model
import Log

public final class NicknameViewController: Common.BaseViewController {
    public override var screenName: ScreenName {
        return .signUp
    }
    
    private let nicknameView = NicknameView()
    private let viewModel: NicknameViewModel
    private let appInterface = Environment.appModuleInterface
    private let myPageInterface = Environment.myPageInterface
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public static func instance(
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
    
    public override func loadView() {
        self.view = self.nicknameView
    }
    
    public override func bindViewModelInput() {
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
    
    public override func bindViewModelOutput() {
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
                    owner.presentPolicy()
                    
                case .goToMain(let bookmarkFolderId):
                    owner.goToMain(with: bookmarkFolderId)
                    
                case .showErrorAlert(let error):
                    owner.showErrorAlert(error: error)
                    
                case .showLoading(let isShow):
                    DesignSystem.LoadingManager.shared.showLoading(isShow: isShow)
                }
            }
            .store(in: &cancellables)
    }
    
    public override func bindEvent() {
        nicknameView.backButton
            .controlPublisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    private func presentPolicy() {
        let viewController = PolicyViewController.instance(delegate: self)
        
        present(viewController, animated: true)
    }
    
    private func goToMain(with bookmarkFolderId: String?) {
        appInterface.goToMain()
    }
}

extension NicknameViewController: PolicyViewControllerDelegate {
    func onDismiss() {
        viewModel.input.onDismissPolicy.send(())
    }
}
