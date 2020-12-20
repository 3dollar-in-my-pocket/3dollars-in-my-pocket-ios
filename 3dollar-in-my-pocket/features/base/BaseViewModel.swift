import RxSwift
import RxCocoa

class BaseViewModel {
  
  let disposeBag = DisposeBag()
  let httpErrorAlert = PublishRelay<HTTPError>()
}
