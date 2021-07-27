import RxSwift
import RxCocoa

class BaseViewModel {
  
  let disposeBag = DisposeBag()
  let showErrorAlert = PublishRelay<Error>()
  let httpErrorAlert = PublishRelay<HTTPError>()
  let showSystemAlert = PublishRelay<AlertContent>()
}
