import UIKit

import Common
import DesignSystem
import Model
import AppInterface
import DependencyInjection

public final class NicknameViewController: Common.BaseViewController {
    private let nicknameView = NicknameView()
    private let viewModel: NicknameViewModel
    private let appInterface: AppModuleInterface
    
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
        guard let appInterface = DIContainer.shared.container.resolve(AppModuleInterface.self) else {
            fatalError("⚠️ AppModuleInterface가 등록되지 않았습니다.")
        }
        
        self.appInterface = appInterface
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
                    fatalError("에러처리 로직 구현 필요")
//                    owner.showErrorAlert(error: error)
                    
                    
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
        
        if let bookmarkFolderId {
            let targetViewController = appInterface.createBookmarkViewerViewController(folderId: bookmarkFolderId)
            let deepLinkContents = DeepLinkContents(
                targetViewController: targetViewController,
                transitionType: .present
            )
            
            appInterface.deeplinkManager.reserveDeeplink(deeplinkContents: deepLinkContents)
        }
    }
}

extension NicknameViewController: PolicyViewControllerDelegate {
    func onDismiss() {
        viewModel.input.onDismissPolicy.send(())
    }
}
