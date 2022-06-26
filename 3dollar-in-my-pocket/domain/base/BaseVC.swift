import UIKit

import Base
import RxSwift

class BaseVC: Base.BaseViewController {
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
    
    func showRootLoading(isShow: Bool) {
        if let tabBarVC = self.navigationController?.parent as? TabBarVC {
            tabBarVC.showLoading(isShow: isShow)
        }
    }
    
    func showRootDim(isShow: Bool) {
        if let tabBarVC = self.navigationController?.parent as? TabBarVC {
            tabBarVC.showDim(isShow: isShow)
        } else {
            self.showDim(isShow: isShow)
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
    
    override func showErrorAlert(error: Error) {
        if let httpError = error as? HTTPError {
            self.showHTTPErrorAlert2(error: httpError)
        } else if let baseError = error as? BaseError {
            self.showBaseErrorAlert(error: baseError)
        } else {
            super.showErrorAlert(error: error)
        }
    }
    
    private func showDim(isShow: Bool) {
        if isShow {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view.addSubview(self.dimView)
                UIView.animate(withDuration: 0.3) {
                    self.dimView.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a: 0.5)
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.3, animations: {
                    self.dimView.backgroundColor = .clear
                }) { (_) in
                    self.dimView.removeFromSuperview()
                }
            }
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
}
