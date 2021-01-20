import RxSwift
import RxCocoa

class WriteDetailViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  let storeService: StoreServiceProtocol
  let address: String
  let location: (Double, Double)
  var appearenceDay: [WeekDay] = []
  var categoryies: [StoreCategory?] = [nil]
  var menusSections: [MenuSection] = []
  
  struct Input {
    let storeName = PublishSubject<String>()
    let tapDay = PublishSubject<WeekDay>()
    let tapAddCategory = PublishSubject<Void>()
    let tapCategoryDelete = PublishSubject<Int>()
    let addCategories = PublishSubject<[StoreCategory?]>()
    let deleteCategory = PublishSubject<Int>()
  }
  
  struct Output {
    let address = PublishRelay<String>()
    let storeNameIsEmpty = PublishRelay<Bool>()
    let selectedDays = PublishRelay<[WeekDay]>()
    let categories = PublishRelay<[StoreCategory?]>()
    let showCategoryDialog = PublishRelay<[StoreCategory?]>()
    let menus = PublishRelay<[MenuSection]>()
    let fetchMenuTableViewHeight = PublishRelay<Void>()
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
    
    self.input.storeName
      .map { $0.isEmpty }
      .bind(to: self.output.storeNameIsEmpty)
      .disposed(by: disposeBag)
    
    self.input.tapDay
      .bind(onNext: self.onTapDay(weekDay:))
      .disposed(by: disposeBag)
    
    self.input.tapAddCategory
      .map { self.categoryies }
      .bind(to: self.output.showCategoryDialog)
      .disposed(by: disposeBag)
    
    self.input.addCategories
      .map {
        $0.map { category -> MenuSection in
          MenuSection(category: category, items: [nil])
        }
      }
      .do(onNext: { self.menusSections = $0 })
      .bind(to: self.output.menus)
      .disposed(by: disposeBag)
    
    self.input.addCategories
      .map { [nil] + $0}
      .do(onNext: { [weak self] selectedCategories in
        self?.categoryies = selectedCategories
      })
      .bind(to: self.output.categories)
      .disposed(by: disposeBag)
    
    self.input.deleteCategory
      .bind(onNext: self.deleteCategory(index:))
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
  
  private func deleteCategory(index: Int) {
    if self.categoryies.count >= index + 1 {
      self.categoryies.remove(at: index + 1)
      Observable.just(self.categoryies)
        .bind(to: self.output.categories)
        .disposed(by: disposeBag)
    }
    
    self.menusSections.remove(at: index)
    Observable.just(self.menusSections)
      .bind(to: self.output.menus)
      .disposed(by: disposeBag)
  }
  
  private func onTapDay(weekDay: WeekDay) {
    if self.appearenceDay.contains(weekDay) {
      let removeIndex = self.appearenceDay.firstIndex(of: weekDay)!
      self.appearenceDay.remove(at: removeIndex)
    } else {
      self.appearenceDay.append(weekDay)
    }
    
    Observable.just(self.appearenceDay)
      .bind(to: self.output.selectedDays)
      .disposed(by: disposeBag)
  }
}
