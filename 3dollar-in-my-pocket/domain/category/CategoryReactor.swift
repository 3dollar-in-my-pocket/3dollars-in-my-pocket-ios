import RxSwift
import RxCocoa
import ReactorKit

final class CategoryReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapBanner
        case tapCategory(index: Int)
    }
    
    enum Mutation {
        case setCategories([MenuCategory])
        case goToWeb(url: String)
        case pushCategoryList(category: StoreCategory)
        case showErrorAlert(Error)
    }
    
    struct State {
        var categories: [MenuCategory] = []
    }
    
    let initialState = State()
    let pushCategoryListPublisher = PublishRelay<StoreCategory>()
    let goToWebPublisher = PublishRelay<String>()
    private let categoryService: CategoryServiceProtocol
  
    init(categoryService: CategoryServiceProtocol) {
        self.categoryService = categoryService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchCategories()
            
        case .tapBanner:
            return .empty()
            
        case .tapCategory(let index):
            let tappedCategory = self.currentState.categories[index].category
            
            self.logGA(category: tappedCategory)
            return .just(.pushCategoryList(category: tappedCategory))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setCategories(let menuCategories):
            newState.categories = menuCategories
            
        case .goToWeb(let url):
            print(url)
            
        case .pushCategoryList(let category):
            self.pushCategoryListPublisher.accept(category)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
  
    
    private func fetchCategories() -> Observable<Mutation> {
        return self.categoryService.fetchCategories()
            .map { $0.map(MenuCategory.init(response:)) }
            .map { .setCategories($0) }
            .catchError { .just(.showErrorAlert($0)) }
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
