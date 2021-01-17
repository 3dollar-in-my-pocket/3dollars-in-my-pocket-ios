import RxSwift
import RxCocoa

class WriteDetailViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  let storeService: StoreServiceProtocol
  let address: String
  let location: (Double, Double)
  let categoryies: [StoreCategory?] = [nil]
  
  struct Input {
    let tapAddCategory = PublishSubject<Void>()
    let tapCategoryDelete = PublishSubject<Int>()
  }
  
  struct Output {
    let address = PublishRelay<String>()
    let categories = PublishRelay<[StoreCategory?]>()
    let showCategoryDialog = PublishRelay<[StoreCategory?]>()
  }
  
  init(
    address: String,
    location: (Double, Double),
    storeService: StoreServiceProtocol
  ) {
    self.address = address
    self.location = location
    self.storeService = storeService
    super.init()
    
    self.input.tapAddCategory
      .debug()
      .map { self.categoryies }
      .bind(to: self.output.showCategoryDialog)
      .disposed(by: disposeBag)
  }
  
  func fetchInitialData() {
    Observable.just(self.address)
      .bind(to: self.output.address)
      .disposed(by: disposeBag)
    
    Observable.just(self.categoryies)
      .bind(to: self.output.categories)
      .disposed(by: disposeBag)
  }
}
