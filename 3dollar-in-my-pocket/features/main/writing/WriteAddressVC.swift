import UIKit
import RxSwift

class WriteAddressVC: BaseVC {
  
  private lazy var writeAddressView = WriteAddressView(frame: self.view.frame)
  
  
  static func instance() -> WriteAddressVC {
    return WriteAddressVC(nibName: nil, bundle: nil).then {
      $0.modalPresentationStyle = .overCurrentContext
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = writeAddressView
  }
  
  override func bindEvent() {
    self.writeAddressView.closeButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismiss)
      .disposed(by: disposeBag)
  }
  
  private func dismiss() {
    self.dismiss(animated: true, completion: nil)
  }
}
