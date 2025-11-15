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
        
        appInterface.deepLinkHandler.handleReservedDeepLink()
        appInterface.requestATTIfNeeded()
    }
    
    public override func bindViewModelInput() {
        signinView.kakaoButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in .kakao }
            .subscribe(viewModel.input.signinWithSocial)
            .store(in: &cancellables)
        
        signinView.appleButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in .apple }
            .subscribe(viewModel.input.signinWithSocial)
            .store(in: &cancellables)
        
        signinView.signinAnonymousButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.signinAnonymous)
            .store(in: &cancellables)
        
        signinView.logoButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapLogo)
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
                    
                case .pushNickname(let socialType, let accessToken, let randomName):
                    let viewController = NicknameViewController.instance(
                        socialType: socialType,
                        accessToken: accessToken,
                        randomName: randomName
                    )
                    
                    owner.navigationController?.pushViewController(viewController, animated: true)
                    
                case .showErrorAlert(let error):
                    owner.showErrorAlert(error: error)
                    
                case .showLoading(let isShow):
                    LoadingManager.shared.showLoading(isShow: isShow)
                    
                case .presentDemoCodeAlert:
                    owner.presentCodeAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    private func presentCodeAlert() {
        let alert = UIAlertController(title: Strings.CodeAlert.title, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: Strings.Common.ok, style: .default) { [weak self] _ in
            guard let code = alert.textFields?.first?.text else { return }
            
            self?.viewModel.input.signinDemo.send(code)
        }
        let cancel = UIAlertAction(title: Strings.Common.cancel, style: .cancel)
        alert.addTextField()
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
