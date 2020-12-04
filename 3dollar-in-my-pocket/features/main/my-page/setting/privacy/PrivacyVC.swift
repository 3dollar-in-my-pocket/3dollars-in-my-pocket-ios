import UIKit
import RxSwift

class PrivacyVC: BaseVC {
  
  private lazy var privacyView = PrivacyView(frame: self.view.frame)
  
  
  static func instance() -> PrivacyVC {
    return PrivacyVC(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = privacyView
    self.loadURL()
  }
  
  override func bindEvent() {
    self.privacyView.backButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.popupVC)
      .disposed(by: disposeBag)
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
  }
  
  private func popupVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func loadURL() {
    guard let url = URL(string: "https://www.notion.so/3-3d0a9c55ddd74086b63582c308ca285e") else {
      return
    }
    let request = URLRequest(url: url)
    
    self.privacyView.webView.load(request)
  }
}
