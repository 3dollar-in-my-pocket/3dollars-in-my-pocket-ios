import RxSwift

class SearchAddressVC: BaseVC {
  
  private lazy var searchAddressView = SearchAddressView(frame: self.view.frame)
  
  static func instacne() -> SearchAddressVC {
    return SearchAddressVC(nibName: nil, bundle: nil).then {
      $0.modalPresentationStyle = .overCurrentContext
    }
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view = searchAddressView
  }
  
  override func bindEvent() {
    self.searchAddressView.closeButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismiss)
      .disposed(by: disposeBag)
  }
  
  private func dismiss() {
    self.dismiss(animated: true, completion: nil)
  }
}
