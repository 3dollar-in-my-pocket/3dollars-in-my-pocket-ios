import UIKit

import Common
import DesignSystem
import Log

public final class SigninViewController: BaseViewController {
    public override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let signinView = SigninView()
    private let viewModel = SigninViewModel()
    private let appInterface = Environment.appModuleInterface
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public static func instance() -> UINavigationController {
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
    
    public override func loadView() {
        self.view = self.signinView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        appInterface.deeplinkManager.flushDelayedDeeplink()
        appInterface.requestATTIfNeeded()
    }
    
    public override func bindViewModelInput() {
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
    
    public override func bindViewModelOutput() {
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .goToMain:
                    owner.appInterface.goToMain()
                    
                case .pushNickname(let socialType, let accessToken):
                    let viewController = NicknameViewController.instance(
                        socialType: socialType,
                        accessToken: accessToken
                    )
                    
                    owner.navigationController?.pushViewController(viewController, animated: true)
                    
                case .showErrorAlert(let error):
                    owner.showErrorAlert(error: error)
                    
                case .showLoading(let isShow):
                    LoadingManager.shared.showLoading(isShow: isShow)
                }
            }
            .store(in: &cancellables)
    }
}
