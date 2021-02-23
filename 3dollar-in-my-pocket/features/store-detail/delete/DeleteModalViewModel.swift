import RxSwift
import RxCocoa

class DeleteModalViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  let storeId: Int
  let storeService: StoreServiceProtocol
  
  struct Input {
    let tapReason = PublishSubject<DeleteReason>()
    let tapDeleteButton = PublishSubject<Void>()
  }
  
  struct Output {
    let requestButtonIsEnable = PublishRelay<Bool>()
    let selectReason = PublishRelay<DeleteReason>()
    let dismiss = PublishRelay<Void>()
    let showLoading = PublishRelay<Bool>()
  }
  
  
  init(storeId: Int, storeService: StoreServiceProtocol) {
    self.storeId = storeId
    self.storeService = storeService
    super.init()
    
    self.input.tapReason
      .do(onNext: { [weak self] _ in
        self?.output.requestButtonIsEnable.accept(true)
      })
      .bind(to: self.output.selectReason)
      .disposed(by: disposeBag)
    
    self.input.tapDeleteButton
      .withLatestFrom(self.output.selectReason) { (self.storeId, $1) }
      .bind(onNext: self.requestDelete)
      .disposed(by: disposeBag)
  }
  
  private func requestDelete(storeId: Int, deleteReason: DeleteReason) {
    self.output.showLoading.accept(true)
    self.storeService.deleteStore(storeId: storeId, deleteReasonType: deleteReason)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          self.output.dismiss.accept(())
          self.output.showLoading.accept(false)
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError {
            self.httpErrorAlert.accept(httpError)
          } else if let error = error as? CommonError {
            let alertContent = AlertContent(title: nil, message: error.description)
            
            self.showSystemAlert.accept(alertContent)
          }
          self.output.showLoading.accept(false)
        }).disposed(by: disposeBag)
  }
}
