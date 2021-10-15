import RxSwift
import RxCocoa

class BaseViewModel {
  let disposeBag = DisposeBag()
  let showErrorAlert = PublishRelay<Error>()
  let showLoading = PublishRelay<Bool>()
  
  // showErrorAlert에서 HTTPError도 처리중!
  let httpErrorAlert = PublishRelay<HTTPError>()
  let showSystemAlert = PublishRelay<AlertContent>()
}
