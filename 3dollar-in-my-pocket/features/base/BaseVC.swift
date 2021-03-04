import UIKit
import RxSwift

class BaseVC: UIViewController {
  
  let disposeBag = DisposeBag()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
    bindEvent()
  }
  
  func bindViewModel() { }
  
  func bindEvent() { }
  
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
}
