import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

final class CategoryReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapBanner
        case tapCategory(index: Int)
    }
    
    enum Mutation {
        case setCategories(categories: [MenuCategory], advertisement: Popup?)
        case goToWeb(url: String)
        case pushCategoryList(category: StoreCategory)
        case showErrorAlert(Error)
    }
    
    struct State {
        var categorySections: [SectionModel<Popup?, MenuCategory>] = []
    }
    
    let initialState = State()
    let pushCategoryListPublisher = PublishRelay<StoreCategory>()
    private let categoryService: CategoryServiceProtocol
    private let popupService: PopupServiceProtocol
  
    init(
        categoryService: CategoryServiceProtocol,
        popupService: PopupServiceProtocol
    ) {
        self.categoryService = categoryService
        self.popupService = popupService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.zip(self.fetchCategories(), self.fetchAdvertisement())
                .map { categories, advertisement -> Mutation in
                    return .setCategories(categories: categories, advertisement: advertisement)
                }
                .catchError { .just(.showErrorAlert($0)) }
            
        case .tapBanner:
            GA.shared.logEvent(event: .category_banner_clicked, page: .category_page)
            guard let url = self.currentState.categorySections[0].model?.linkUrl else {
                return .empty()
            }
            
            return .just(.goToWeb(url: url))
            
        case .tapCategory(let index):
            let tappedCategory = self.currentState.categorySections[0].items[index].category
            
            self.logGA(category: tappedCategory)
            return .just(.pushCategoryList(category: tappedCategory))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setCategories(let menuCategories, let advertisement):
            newState.categorySections = [SectionModel(model: advertisement, items: menuCategories)]
            
        case .goToWeb(let url):
            self.openURLPublisher.accept(url)
            
        case .pushCategoryList(let category):
            self.pushCategoryListPublisher.accept(category)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
  
    
    private func fetchCategories() -> Observable<[MenuCategory]> {
        return self.categoryService.fetchCategories()
            .map { $0.map(MenuCategory.init(response:)) }
    }
    
    private func fetchAdvertisement() -> Observable<Popup?> {
        return self.popupService.fetchPopups(position: .menuCategoryBanner)
            .map { $0.map(Popup.init(response:)).first }
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
