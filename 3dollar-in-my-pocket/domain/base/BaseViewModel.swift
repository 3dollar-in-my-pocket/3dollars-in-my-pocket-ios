import RxSwift
import RxCocoa

class BaseViewModel {
  
  let disposeBag = DisposeBag()
  let showErrorAlert = PublishRelay<Error>()
  
  // showErrorAlert에서 HTTPError도 처리중!
  let httpErrorAlert = PublishRelay<HTTPError>()
  let showSystemAlert = PublishRelay<AlertContent>()
}
