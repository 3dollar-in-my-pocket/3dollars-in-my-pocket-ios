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
}
