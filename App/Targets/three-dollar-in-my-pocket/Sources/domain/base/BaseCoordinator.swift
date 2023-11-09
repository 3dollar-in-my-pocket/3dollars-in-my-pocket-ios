import UIKit

protocol BaseCoordinator {
    var presenter: BaseViewController { get }
    
    func showErrorAlert(error: Error)
    func openURL(url: String)
    func showLoading(isShow: Bool)
    func showToast(message: String)
    func showToast(message: String, baseView: UIView)
    func dismiss(completion: (() -> Void)?)
    func dismiss()
}

extension BaseCoordinator where Self: BaseViewController {
    var presenter: BaseViewController {
        return self
    }
    
    func showErrorAlert(error: Error) {
        if let httpError = error as? HTTPError {
            if httpError == .unauthorized {
                AlertUtils.showWithAction(
                    viewController: self,
                    title: nil,
                    message: httpError.description,
                    okbuttonTitle: "확인"
                ) {
                    UserDefaultsUtil().clear()
                    self.goToSignin()
                }
            } else {
                AlertUtils.showWithAction(
                    viewController: self,
                    message: httpError.description,
                    onTapOk: nil
                )
            }
        } else if let localizedError = error as? LocalizedError {
            AlertUtils.showWithAction(
                viewController: self,
                message: localizedError.errorDescription,
                onTapOk: nil
            )
        } else {
            AlertUtils.showWithAction(
                viewController: self,
                message: error.localizedDescription,
                onTapOk: nil
            )
        }
    }
    
    func openURL(url: String) {
        guard let url = URL(string: url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func showLoading(isShow: Bool) {
        LoadingManager.shared.showLoading(isShow: isShow)
    }
    
    func showToast(message: String, baseView: UIView) {
        ToastManager.shared.show(message: message, baseView: baseView)
    }
    
    func showToast(message: String) {
        ToastManager.shared.show(message: message)
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        if presenter is BaseBottomSheetViewController {
            DimManager.shared.hideDim()
        }
        presenter.dismiss(animated: true, completion: completion)
    }
    
    func dismiss() {
        dismiss(completion: nil)
    }
    
    private func goToSignin() {
        if let sceneDelegate
            = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.goToSignIn()
        }
    }
}
