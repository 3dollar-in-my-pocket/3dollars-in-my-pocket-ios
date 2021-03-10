import RxSwift
import RxCocoa

class PhotoDetailViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let storeService: StoreServiceProtocol
  let storeId: Int
  var selectedIndex: Int
  var photos: [Image]
  
  struct Input {
    let selectPhoto = PublishSubject<Int>()
    let tapDelete = PublishSubject<Void>()
  }
  
  struct Output {
    let mainPhotos = PublishRelay<[Image]>()
    let subPhotos = PublishRelay<[Image]>()
    let selectPhoto = PublishRelay<Int>()
    let dismiss = PublishRelay<Void>()
    let showLoading = PublishRelay<Bool>()
  }
  
  
  init(
    storeId: Int,
    selectedIndex: Int,
    photos: [Image],
    storeService: StoreServiceProtocol
  ) {
    self.storeId = storeId
    self.selectedIndex = selectedIndex
    self.photos = photos
    self.storeService = storeService
    super.init()
    
    self.input.selectPhoto
      .bind { [weak self] index in
        self?.selectedIndex = index
      }
      .disposed(by: disposeBag)
    
    self.input.tapDelete
      .map { (self.storeId, self.selectedIndex) }
      .bind(onNext: self.deletePhoto)
      .disposed(by: disposeBag)
  }
  
  func fetchPhotos(){
    self.output.mainPhotos.accept(self.photos)
    self.output.subPhotos.accept(self.photos)
    self.output.selectPhoto.accept(selectedIndex)
  }
  
  private func deletePhoto(storeId: Int, selectedIndex: Int) {
    self.output.showLoading.accept(true)
    
    self.storeService.deletePhoto(storeId: storeId, photoId: self.photos[selectedIndex].id)
      .subscribe(
        onNext: { [weak self] _ in
          guard let self = self else { return }
          
          self.photos.remove(at: selectedIndex)
          if self.photos.isEmpty {
            self.output.dismiss.accept(())
          } else {
            self.selectedIndex = self.selectedIndex - 1 < 0 ? 0 : self.selectedIndex - 1
            self.fetchPhotos()
          }
          self.output.showLoading.accept(false)
        },
        onError: { error in
          if let httpError = error as? HTTPError {
            self.httpErrorAlert.accept(httpError)
          }
          if let commonError = error as? CommonError {
            let alertContent = AlertContent(title: nil, message: commonError.description)
            
            self.showSystemAlert.accept(alertContent)
          }
          self.output.showLoading.accept(false)
        }
      )
      .disposed(by: disposeBag)
  }
}
