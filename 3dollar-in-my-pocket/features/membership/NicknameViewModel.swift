import RxSwift
import RxCocoa

class NicknameViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let id: Int
  let token: String
  
  struct Input {
    let nickname = PublishSubject<String>()
    let tapStartButton = PublishSubject<Void>()
  }
  
  struct Output {
    let showLoading = PublishRelay<Bool>()
    let setButtonEnable = PublishRelay<Bool>()
    let goToMain = PublishRelay<Void>()
    let errorLabel = PublishRelay<String>()
    let showSystemAlert = PublishRelay<AlertContent>()
  }
  
  let userDefaults: UserDefaultsUtil
  let userService: UserServiceProtocol
  
  
  init(
    id: Int,
    token: String,
    userDefaults: UserDefaultsUtil,
    userService: UserServiceProtocol
  ) {
    self.id = id
    self.token = token
    self.userDefaults = userDefaults
    self.userService = userService
    super.init()
    
    self.input.nickname
      .map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
      .bind(to: self.output.setButtonEnable)
      .disposed(by: disposeBag)
    
    self.input.tapStartButton
      .withLatestFrom(self.input.nickname)
      .bind(onNext: self.setNickname(nickname:))
      .disposed(by: disposeBag)
  }
  
  private func setNickname(nickname: String) {
    self.output.showLoading.accept(true)
    self.userService.setNickname(
      nickname: nickname,
      id: self.id,
      token: self.token
    )
    .subscribe { [weak self] _ in
      guard let self = self else { return }
      self.userDefaults.setUserToken(token: self.token)
      self.userDefaults.setUserId(id: self.id)
      self.output.showLoading.accept(false)
      self.output.goToMain.accept(())
    } onError: { error in
      if let error = error as? HTTPError {
        if error == HTTPError.badRequest {
          self.output.errorLabel.accept("nickname_alreay_existed".localized)
        } else {
          self.httpErrorAlert.accept(error)
        }
      } else if let error = error as? CommonError {
        let alertContent = AlertContent(title: nil, message: error.description)
        
        self.output.showSystemAlert.accept(alertContent)
      }
      self.output.showLoading.accept(false)
    }
    .disposed(by: disposeBag)
  }
}
