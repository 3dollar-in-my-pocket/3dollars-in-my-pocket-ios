import RxSwift
import RxCocoa

class PopupViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  let event: Event
  let userDefaults: UserDefaultsUtil
  
  struct Input {
    let tapBannerButton = PublishSubject<Void>()
    let tapDisableButton = PublishSubject<Void>()
  }
  
  struct Output {
    let dismiss = PublishRelay<Void>()
  }
  

  init(event: Event, userDefaults: UserDefaultsUtil) {
    self.event = event
    self.userDefaults = userDefaults
    super.init()
    
    self.input.tapBannerButton
      .map { self.event }
      .bind(onNext: self.openEventURL(event:))
      .disposed(by: disposeBag)
    
    self.input.tapDisableButton
      .map { self.event}
      .bind(onNext: self.setDisableToday(event:))
      .disposed(by: disposeBag)
  }
  
  private func openEventURL(event: Event) {
    guard let url = URL(string: event.url),
          UIApplication.shared.canOpenURL(url) else { return }
    
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
    self.output.dismiss.accept(())
  }
  
  private func setDisableToday(event: Event) {
    self.userDefaults.setEventDisableToday(id: event.id)
    self.output.dismiss.accept(())
  }
}
