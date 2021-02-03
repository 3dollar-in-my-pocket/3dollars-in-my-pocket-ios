import RxSwift
import RxCocoa

class PhotoListViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let storeId: Int
  let photos: [Image]
  
  struct Input {
    let tapPhoto = PublishSubject<Int>()
  }
  
  struct Output {
    let photos = PublishRelay<[Image]>()
    let showPhotoDetail = PublishRelay<(Int, Int, [Image])>()
  }
  
  init(storeId: Int, photos: [Image]) {
    self.storeId = storeId
    self.photos = photos
    super.init()
    
    self.input.tapPhoto
      .map { (self.storeId, $0, self.photos)}
      .bind(to: self.output.showPhotoDetail)
      .disposed(by: disposeBag)
  }
  
  func fetchPhotos(){
    self.output.photos.accept(self.photos)
  }
}
