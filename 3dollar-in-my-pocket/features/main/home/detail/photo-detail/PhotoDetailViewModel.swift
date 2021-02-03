import RxSwift
import RxCocoa

class PhotoDetailViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let storeService: StoreServiceProtocol
  let selectedIndex: Int
  var photos: [Image]
  
  struct Input {
    
  }
  
  struct Output {
    let mainPhotos = PublishRelay<[Image]>()
    let subPhotos = PublishRelay<[Image]>()
    let selectPhoto = PublishRelay<Int>()
    let showLoading = PublishRelay<Bool>()
  }
  
  
  init(
    selectedIndex: Int,
    photos: [Image],
    storeService: StoreServiceProtocol
  ) {
    self.selectedIndex = selectedIndex
    self.photos = photos
    self.storeService = storeService
    super.init()
  }
  
  func fetchPhotos(){
    self.output.mainPhotos.accept(self.photos)
    self.output.subPhotos.accept(self.photos)
    self.output.selectPhoto.accept(selectedIndex)
  }
}
