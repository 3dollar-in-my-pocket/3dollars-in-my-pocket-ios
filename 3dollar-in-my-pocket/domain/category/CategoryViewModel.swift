import RxSwift
import RxCocoa

class CategoryViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  var categories: [MenuCategoryResponse] = []
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let tapCategory = PublishSubject<Int>()
  }
  
  struct Output {
    let categories = PublishRelay<[MenuCategoryResponse]>()
    let goToCategoryList = PublishRelay<StoreCategory>()
  }
  
  let categoryService: CategoryServiceProtocol
  
  init(categoryService: CategoryServiceProtocol) {
    self.categoryService = categoryService
    super.init()
    
    self.input.viewDidLoad
      .bind(onNext: self.fetchCategories)
      .disposed(by: self.disposeBag)
    
    self.input.tapCategory
      .map { self.categories[$0].category }
      .bind(to: self.output.goToCategoryList)
      .disposed(by: disposeBag)
  }
  
  func fetchCategories() {
    self.categoryService.fetchCategories()
      .do(onNext: { [weak self] menuCategoryResponse in
        self?.categories = menuCategoryResponse
      })
      .bind(to: self.output.categories)
      .disposed(by: self.disposeBag)
  }
  
  private func logGA(category: StoreCategory) {
    switch category {
    case .BUNGEOPPANG:
      GA.shared.logEvent(event: .bungeoppang_button_clicked, page: .category_page)
    case .TAKOYAKI:
      GA.shared.logEvent(event: .takoyaki_button_clicked, page: .category_page)
    case .GYERANPPANG:
      GA.shared.logEvent(event: .gyeranppang_button_clicked, page: .category_page)
    case .HOTTEOK:
      GA.shared.logEvent(event: .hotteok_button_clicked, page: .category_page)
    case .EOMUK:
      GA.shared.logEvent(event: .eomuk_button_clicked, page: .category_page)
    case .GUNGOGUMA:
      GA.shared.logEvent(event: .gungoguma_button_clicked, page: .category_page)
    case .TTEOKBOKKI:
      GA.shared.logEvent(event: .tteokbokki_button_clicked, page: .category_page)
    case .TTANGKONGPPANG:
      GA.shared.logEvent(event: .ttangkongppang_button_clicked, page: .category_page)
    case .GUNOKSUSU:
      GA.shared.logEvent(event: .gunoksusu_button_clicked, page: .category_page)
    case .KKOCHI:
      GA.shared.logEvent(event: .kkochi_button_clicked, page: .category_page)
    case .TOAST:
      GA.shared.logEvent(event: .toast_button_clicked, page: .category_page)
    case .WAFFLE:
      GA.shared.logEvent(event: .waffle_button_clicked, page: .category_page)
    case .GUKWAPPANG:
      GA.shared.logEvent(event: .gukwappang_button_clicked, page: .category_page)
    case .SUNDAE:
      GA.shared.logEvent(event: .sundae_button_clicked, page: .category_page)
    case .DALGONA:
      GA.shared.logEvent(event: .dalgona_button_clicked, page: .category_page)
    }
  }
}
