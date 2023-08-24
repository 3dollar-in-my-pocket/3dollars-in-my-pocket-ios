import UIKit

import Common
import DesignSystem

final class SigninViewController: Common.BaseViewController {
    private let signinView = SigninView()
    private let viewModel = SigninViewModel()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> UINavigationController {
        let controller = SigninViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        
        navigationController.isNavigationBarHidden = true
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        return navigationController
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.signinView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DeeplinkManager.shared.flushDelayedDeeplink()
    }
    
    override func bindViewModelInput() {
        signinView.kakaoButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in .kakao }
            .subscribe(viewModel.input.onTapSignin)
            .store(in: &cancellables)
        
        signinView.appleButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in .apple }
            .subscribe(viewModel.input.onTapSignin)
            .store(in: &cancellables)
        
        signinView.signinAnonymousButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapSigninAnonymous)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .goToMain:
                    owner.goToMain()
                    
                case .pushNickname(let socialType, let accessToken):
                    let viewController = NicknameViewController.instance(
                        socialType: socialType,
                        accessToken: accessToken
                    )
                    
                    owner.navigationController?.pushViewController(viewController, animated: true)
                    
                case .showErrorAlert(let error):
                    owner.showErrorAlert(error: error)
                    
                case .showLoading(let isShow):
                    DesignSystem.LoadingManager.shared.showLoading(isShow: isShow)
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleDeeplink(contents: DeepLinkContents) {
        let rootViewController = SceneDelegate.shared?.window?.rootViewController
        
        guard let targetViewController = contents.targetViewController,
              let transitionType = contents.transitionType else { return }
        
        switch transitionType {
        case .push:
            if let navigationController = rootViewController as? UINavigationController {
                navigationController.pushViewController(
                    targetViewController,
                    animated: true
                )
            } else {
                Log.error("UINavigationViewController가 없습니다.")
            }
            
        case .present:
            rootViewController?.present(targetViewController, animated: true)
        }
    }
    
    private func goToMain() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
        sceneDelegate.goToMain()
    }
}
