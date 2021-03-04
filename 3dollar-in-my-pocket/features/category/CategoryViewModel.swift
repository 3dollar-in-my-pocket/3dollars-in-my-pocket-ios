import RxSwift
import RxCocoa

class CategoryViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let categories: [StoreCategory] = [
    .BUNGEOPPANG, .KKOCHI, .EOMUK,
    .GUKWAPPANG, .GUNGOGUMA, .GYERANPPANG,
    .HOTTEOK, .GUNOKSUSU, .SUNDAE,
    .TAKOYAKI, .TOAST, .TTANGKONGPPANG,
    .TTEOKBOKKI, .WAFFLE
  ]
  
  struct Input {
    let tapCategory = PublishSubject<Int>()
  }
  
  struct Output {
    let categories = PublishRelay<[StoreCategory]>()
    let goToCategoryList = PublishRelay<StoreCategory>()
  }
  
  override init() {
    super.init()
    
    self.input.tapCategory
      .map { self.categories[$0] }
      .bind(to: self.output.goToCategoryList)
      .disposed(by: disposeBag)
  }
  
  func fetchCategories() {
    self.output.categories.accept(self.categories)
  }
}
