import RxSwift
import RxCocoa

class PhotoListViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let storeId: Int
  let storeService: StoreServiceProtocol
  
  struct Input {
    let tapPhoto = PublishSubject<Int>()
  }
  
  struct Output {
    let photos = PublishRelay<[Image]>()
    let showPhotoDetail = PublishRelay<(Int, Int, [Image])>()
    let showLoading = PublishRelay<Bool>()
  }
  
  init(storeId: Int, storeService: StoreServiceProtocol) {
    self.storeId = storeId
    self.storeService = storeService
    super.init()
    
    self.input.tapPhoto
      .withLatestFrom(self.output.photos) { (self.storeId, $0, $1)}
      .bind(to: self.output.showPhotoDetail)
      .disposed(by: disposeBag)
  }
  
  func fetchPhotos(){
    self.output.showLoading.accept(true)
    self.storeService.getPhotos(storeId: self.storeId)
      .subscribe { [weak self] photos in
        guard let self = self else { return }
        self.output.photos.accept(photos)
        self.output.showLoading.accept(false)
      } onError: { [weak self] error in
        guard let self = self else { return }
        if let httpError = error as? HTTPError {
          self.httpErrorAlert.accept(httpError)
        }
        self.output.showLoading.accept(false)
      }
      .disposed(by: disposeBag)
  }
}
