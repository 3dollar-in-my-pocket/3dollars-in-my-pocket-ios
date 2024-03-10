import UIKit

import RxSwift

class BaseVC: UIViewController {
    var disposeBag = DisposeBag()
    var eventDisposeBag = DisposeBag()
    
    private lazy var dimView = UIView(frame: self.view.frame).then {
        $0.backgroundColor = .clear
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        bindViewModelInput()
        bindViewModelOutput()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        bindEvent()
    }
    
    func bindEvent() { }
    
    func bindViewModel() { }
    
    func bindViewModelInput() { }
    
    func bindViewModelOutput() { }
    
    func showErrorAlert(error: Error) {
        if let httpError = error as? HTTPError {
            self.showHTTPErrorAlert2(error: httpError)
        } else if let baseError = error as? BaseError {
            self.showBaseErrorAlert(error: baseError)
        } else {
            AlertUtils.showWithAction(
                viewController: self,
                message: error.localizedDescription,
                onTapOk: nil
            )
        }
    }
    
    private func showHTTPErrorAlert2(error: HTTPError) {
        if error == HTTPError.maintenance {
            AlertUtils.showWithAction(
                title: "error_maintenance_title".localized,
                message: "error_maintenance_message".localized
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
