import UIKit

import Common
import Model

final class SplashViewController: BaseViewController {
    private let splashView = SplashView()
    private let viewModel = SplashViewModel()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        view = splashView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForegroundNotification(_:)),
            name: UIScene.willEnterForegroundNotification,
            object: nil
        )
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func bindViewModelOutput() {
        viewModel.output.route
            .withUnretained(self)
            .sink { (owner: SplashViewController, route: SplashViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: SplashViewModel.Route) {
        switch route {
        case .goToSignIn:
            goToSignIn()
        case .goToMain:
            goToMain()
        case .goToSignInWithAlert(let alertContent):
            showGoToSignInAlert(alertContent: alertContent)
        case .showMaintenanceAlert(let alertContent):
            showMaintenanceAlert(alertContent: alertContent)
        case .showUpdateAlert:
            showUpdateAlert()
        }
    }
    
    private func goToMain() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.goToMain()
        }
    }
    
    private func goToSignIn() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.goToSignIn()
        }
    }
    
    private func showGoToSignInAlert(alertContent: AlertContent) {
        AlertUtils.showWithAction(
            viewController: self,
            title: alertContent.title,
            message: alertContent.message
        ) { [weak self] in
            self?.goToSignIn()
        }
    }
    
    private func showMaintenanceAlert(alertContent: AlertContent) {
        AlertUtils.showWithAction(
            viewController: self,
            title: alertContent.title,
            message: alertContent.message
        ) {
            UIControl().sendAction(
                #selector(URLSessionTask.suspend),
                to: UIApplication.shared,
                for: nil
            )
        }
    }
    
    private func showUpdateAlert() {
        AlertUtils.showWithAction(
            viewController: self,
            title: Strings.splashNeedUpdateTitle,
            message: Strings.splashNeedUpdateDescription
        ) {
            if let url = URL(string: "itms-apps://itunes.apple.com/app/1496099467"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc private func willEnterForegroundNotification(_ notification: Notification) {
        splashView.startAnimation { [weak self] in
            self?.viewModel.input.viewDidLoad.send(())
        }
    }
}
