import RxSwift
import RxCocoa
import DeviceKit

class QestionViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let userService: UserServiceProtocol
  let userDefaults: UserDefaultsUtil
  
  let nickname = PublishSubject<String>()
  
  struct Input {
    let tapMail = PublishSubject<Void>()
  }
  
  struct Output {
    let showMailComposer = PublishRelay<(
      iosVersion: String,
      nickname: String,
      appVersion: String,
      deviceModel: Device
    )>()
    let showSystemAlert = PublishRelay<AlertContent>()
    let showLoading = PublishRelay<Bool>()
  }
  
  
  init(
    userService: UserServiceProtocol,
    userDefaults: UserDefaultsUtil
  ) {
    self.userService = userService
    self.userDefaults = userDefaults
    super.init()
    
    self.input.tapMail
      .withLatestFrom(self.nickname)
      .bind { [weak self] nickname in
        guard let self = self else { return }
        let iosVersion = self.getiOSVersion()
        let appVersion = self.getAppVersion()
        let deviceModel = self.getDeviceModel()
        
        self.output.showMailComposer.accept((
          iosVersion,
          nickname,
          appVersion,
          deviceModel
        ))
      }
      .disposed(by: disposeBag)
  }
  
  func fetchMyInfo() {
    self.userService.getUserInfo(userId: self.userDefaults.getUserId())
      .map { $0.nickname ?? "" }
      .subscribe(
        onNext: self.nickname.onNext,
        onError: { [weak self] error in
          if let httpError = error as? HTTPError {
            self?.httpErrorAlert.accept(httpError)
          }
        })
      .disposed(by: disposeBag)
  }
  
  private func getiOSVersion() -> String {
    return  UIDevice.current.systemVersion
  }
  
  private func getAppVersion() -> String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
  }
  
  private func getDeviceModel() -> Device {
    return Device.current
  }
}
