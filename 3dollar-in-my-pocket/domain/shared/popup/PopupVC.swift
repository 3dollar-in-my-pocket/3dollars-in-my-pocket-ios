import UIKit
import RxSwift

class PopupVC: BaseVC {
  
  private lazy var popupView = PopupView.init(frame: self.view.frame)
  
  private let viewModel: PopupViewModel
  private let event: Event
  
  // MARK: Initilize
  init(event: Event) {
    self.event = event
    self.viewModel = PopupViewModel(event: event, userDefaults: UserDefaultsUtil())
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(event: Event) -> PopupVC {
    return PopupVC(event: event).then {
      $0.modalPresentationStyle = .fullScreen
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view = popupView
    popupView.bind(event: event)
  }
  
  override func bindViewModel() {
    // Bind input
    self.popupView.bannerButton.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .bind(to: self.viewModel.input.tapBannerButton)
      .disposed(by: disposeBag)
    
    self.popupView.disableTodayButton.rx.tap
      .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
      .bind(to: self.viewModel.input.tapDisableButton)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.dismiss
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.dismiss)
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    popupView.cancelButton.rx.tap.bind { [weak self] in
      self?.dismiss(animated: true, completion: nil)
    }.disposed(by: disposeBag)
  }
  
  private func dismiss() {
    self.dismiss(animated: true, completion: nil)
  }
}
