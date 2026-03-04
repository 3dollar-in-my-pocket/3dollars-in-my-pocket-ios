import UIKit

import Common
import Model
import Log

final class SplashViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }

    private let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Assets.icSplash.image
        return imageView
    }()

    private let adView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let viewModel = SplashViewModel()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupNotification()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func bindViewModelOutput() {
        viewModel.output.advertisement
            .main
            .withUnretained(self)
            .sink { (owner: SplashViewController, advertisement: AdvertisementResponse) in
                owner.setAdvertisement(advertisement)
            }
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: SplashViewController, route: SplashViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)

        viewModel.output.showDefaultAlert
            .main
            .sink { [weak self] in
                self?.showDefaultAlert()
            }
            .store(in: &cancellables)

        viewModel.output.showRetryAlert
            .main
            .sink { [weak self] _ in
                self?.showRetryAlert()
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        view.backgroundColor = Colors.gray100.color

        view.addSubview(icon)
        icon.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(72)
        }

        view.addSubview(adView)
        adView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(0)
        }
    }

    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    private func setAdvertisement(_ advertisement: AdvertisementResponse) {
        guard let image = advertisement.image else { return }

        if let width = image.width,
           let height = image.height {
            let ratio = Double(height) / Double(width)
            adView.snp.updateConstraints {
                $0.height.equalTo(UIUtils.windowBounds.width * ratio)
            }
        } else {
            adView.snp.updateConstraints {
                $0.height.equalTo(200)
            }
        }

        adView.setImage(urlString: image.url)
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
        case .showUpdateAlert(let title, let message, let url):
            showUpdateAlert(title: title, message: message, url: url)
        }
    }

    private func goToMain() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.goToMain()
            }
        }
    }

    private func goToSignIn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.goToSignIn()
            }
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

    private func showUpdateAlert(title: String, message: String, url: URL?) {
        AlertUtils.showWithAction(
            viewController: self,
            title: title,
            message: message
        ) {
            if let url, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    @objc private func handleWillEnterForeground() {
        viewModel.input.load.send(())
    }

    private func showDefaultAlert() {
        AlertUtils.showWithAction(
            viewController: self,
            message: Strings.Splash.defaultError
        ) {
            UIControl().sendAction(
                #selector(URLSessionTask.suspend),
                to: UIApplication.shared,
                for: nil
            )
        }
    }

    private func showRetryAlert() {
        AlertUtils.showWithTwoActions(
            viewController: self,
            message: Strings.Splash.defaultError,
            leftButtonTitle: "취소",
            rightButtonTitle: "재시도",
            onTapLeft: {
                UIControl().sendAction(
                    #selector(URLSessionTask.suspend),
                    to: UIApplication.shared,
                    for: nil
                )
            },
            onTapRight: { [weak self] in
                self?.viewModel.input.load.send(())
            }
        )
    }
}
