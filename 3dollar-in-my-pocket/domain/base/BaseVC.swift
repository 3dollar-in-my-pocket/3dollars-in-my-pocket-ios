import UIKit
import RxSwift

class BaseVC: UIViewController {
    let disposeBag = DisposeBag()
    
    private lazy var dimView = UIView(frame: self.view.frame).then {
        $0.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        self.bindViewModelInput()
        self.bindViewModelOutput()
        bindEvent()
    }
    
    func bindViewModel() { }
    
    func bindViewModelInput() { }
    
    func bindViewModelOutput() { }
    
    func bindEvent() { }
    
    func showRootLoading(isShow: Bool) {
        if let tabBarVC = self.navigationController?.parent as? TabBarVC {
            tabBarVC.showLoading(isShow: isShow)
        }
    }
    
    func showRootDim(isShow: Bool) {
        if let tabBarVC = self.navigationController?.parent as? TabBarVC {
            tabBarVC.showDim(isShow: isShow)
        }
    }
    
    func showSystemAlert(alert: AlertContent) {
        AlertUtils.show(controller: self, title: alert.title, message: alert.message)
    }
    
    func showHTTPErrorAlert(error: HTTPError) {
        if error == HTTPError.maintenance {
            AlertUtils.showWithAction(
                title: "error_maintenance_title".localized,
                message: "error_maintenance_message".localized) { _ in
                UIControl().sendAction(
                    #selector(URLSessionTask.suspend),
                    to: UIApplication.shared,
                    for: nil
                )
            }
        } else {
            AlertUtils.show(
                controller: self,
                title: nil,
                message: error.description
            )
        }
    }
    
    func showErrorAlert(error: Error) {
        if let httpError = error as? HTTPError {
            self.showHTTPErrorAlert2(error: httpError)
        } else if let baseError = error as? BaseError {
            self.showBaseErrorAlert(error: baseError)
        } else {
            self.showDefaultErrorAlert(error: error)
        }
    }
    
    private func showHTTPErrorAlert2(error: HTTPError) {
        if error == HTTPError.maintenance {
            AlertUtils.showWithAction(
                title: R.string.localization.error_maintenance_title(),
                message: R.string.localization.error_maintenance_message()
            ) { _ in
                UIControl().sendAction(
                    #selector(URLSessionTask.suspend),
                    to: UIApplication.shared,
                    for: nil
                )
            }
        } else if error == HTTPError.unauthorized {
            AlertUtils.showWithAction(
                controller: self,
                title: nil,
                message: error.description) {
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.goToSignIn()
                }
            }
        } else {
            AlertUtils.show(
                controller: self,
                title: nil,
                message: error.description
            )
        }
    }
    
    private func showBaseErrorAlert(error: BaseError) {
        AlertUtils.show(
            controller: self,
            title: nil,
            message: error.errorDescription
        )
    }
    
    private func showDefaultErrorAlert(error: Error) {
        if let localizedError = error as? LocalizedError {
            AlertUtils.show(
                controller: self,
                title: nil,
                message: localizedError.errorDescription
            )
        } else {
            AlertUtils.show(
                controller: self,
                title: nil,
                message: error.localizedDescription
            )
        }
    }
}
