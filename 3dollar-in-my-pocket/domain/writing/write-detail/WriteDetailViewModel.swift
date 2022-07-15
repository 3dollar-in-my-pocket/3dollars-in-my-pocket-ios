import Foundation

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
  var paymentType: [PaymentType] = []
  
  struct Input {
    let storeName = PublishSubject<String>()
    let tapDay = PublishSubject<WeekDay>()
    let tapStoreType = BehaviorSubject<StreetFoodStoreType?>(value: nil)
    let tapPaymentType = PublishSubject<PaymentType>()
    let tapAddCategory = PublishSubject<Void>()
    let tapCategoryDelete = PublishSubject<Int>()
    let addCategories = PublishSubject<[StoreCategory]>()
    let deleteAllCategories = PublishSubject<Void>()
    let menuName = PublishSubject<(IndexPath, String)>()
    let menuPrice = PublishSubject<(IndexPath, String)>()
    let deleteCategory = PublishSubject<Int>()
    let tapRegister = PublishSubject<Void>()
  }
  
  struct Output {
    let address = PublishRelay<String>()
    let storeNameIsEmpty = PublishRelay<Bool>()
    let selectType = PublishRelay<StreetFoodStoreType?>()
    let selectPaymentType = PublishRelay<[PaymentType]>()
    let selectDays = PublishRelay<[WeekDay]>()
    let categories = PublishRelay<[StoreCategory?]>()
    let showCategoryDialog = PublishRelay<[StoreCategory?]>()
    let menus = PublishRelay<[MenuSection]>()
    let fetchMenuTableViewHeight = PublishRelay<Void>()
    let registerButtonIsEnable = PublishRelay<Bool>()
    let dismissAndGoDetail = PublishRelay<Int>()
    let showLoading = PublishRelay<Bool>()
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
    
    self.input.storeName
      .map { !$0.isEmpty && !self.categoryies.compactMap { $0 }.isEmpty }
      .bind(to: self.output.registerButtonIsEnable)
      .disposed(by: disposeBag)
    
    self.input.tapDay
      .bind(onNext: self.onTapDay(weekDay:))
      .disposed(by: disposeBag)
    
    self.input.tapStoreType
      .bind(to: self.output.selectType)
      .disposed(by: disposeBag)
    
    self.input.tapPaymentType
      .bind(onNext: self.onTapPayment(paymentType:))
      .disposed(by: disposeBag)
    
    self.input.tapAddCategory
      .map { self.categoryies }
      .bind(to: self.output.showCategoryDialog)
      .disposed(by: disposeBag)
    
    self.input.addCategories
      .bind(onNext: self.onAddCategory(categories:))
      .disposed(by: disposeBag)
    
    self.input.deleteAllCategories
      .bind(onNext: self.onTapDeleteAllCategories)
      .disposed(by: disposeBag)
    
    self.input.menuName
      .bind(onNext: self.onEditMenuName)
      .disposed(by: disposeBag)
    
    self.input.menuPrice
      .bind(onNext: self.onEditMenuPrice)
      .disposed(by: disposeBag)
    
    self.input.deleteCategory
      .bind(onNext: self.deleteCategory(index:))
      .disposed(by: disposeBag)
    
    self.input.tapRegister
      .withLatestFrom(Observable.combineLatest(self.input.storeName, self.input.tapStoreType))
      .map { Store(
        appearanceDays: self.appearenceDay,
        categories: self.categoryies.compactMap { $0 },
        latitude: self.location.0,
        longitude: self.location.1,
        menuSections: self.menusSections,
        paymentType: self.paymentType,
        storeName: $0.0,
        storeType: $0.1
      ) }
      .bind(onNext: self.saveStore(store:))
      .disposed(by: disposeBag)
    
    self.output.categories
      .withLatestFrom(self.input.storeName) { !$0.compactMap { $0 }.isEmpty && !$1.isEmpty }
      .bind(to: self.output.registerButtonIsEnable)
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
      .bind(to: self.output.selectDays)
      .disposed(by: disposeBag)
  }
  
  private func onTapPayment(paymentType: PaymentType) {
    if self.paymentType.contains(paymentType) {
      let removeIndex = self.paymentType.firstIndex(of: paymentType)!
      
      self.paymentType.remove(at: removeIndex)
    } else {
      self.paymentType.append(paymentType)
    }
    
    Observable.just(self.paymentType)
      .bind(to: self.output.selectPaymentType)
      .disposed(by: disposeBag)
  }
  
  private func onAddCategory(categories: [StoreCategory]) {
    var newMenuSection: [MenuSection] = []
    
    for category in categories{
      if self.categoryies.contains(category){
        for menuSection in self.menusSections {
          if menuSection.category == category {
            newMenuSection.append(menuSection)
            break
          }
        }
      } else {
        newMenuSection.append(MenuSection(category: category, items: [Menu(category: category)]))
      }
    }
    
    self.menusSections = newMenuSection
    self.categoryies = [nil] + categories
    self.output.categories.accept(self.categoryies)
    self.output.menus.accept(self.menusSections)
  }
  
  private func onTapDeleteAllCategories() {
    self.categoryies = [nil]
    self.menusSections = []
    
    self.output.categories.accept(categoryies)
    self.output.menus.accept(menusSections)
  }
  
  private func onEditMenuName(indexPath: IndexPath, name: String) {
    if !name.isEmpty {
      self.menusSections[indexPath.section].items[indexPath.row].name = name
      if self.menusSections[indexPath.section].items.count == indexPath.row + 1 {
        self.menusSections[indexPath.section].items.append(Menu(category: self.menusSections[indexPath.section].category))
        
        self.output.menus.accept(self.menusSections)
      }
    }
  }
  
  private func onEditMenuPrice(indexPath: IndexPath, price: String) {
    if !price.isEmpty {
      self.menusSections[indexPath.section].items[indexPath.row].price = price
      if self.menusSections[indexPath.section].items.count == indexPath.row + 1 {
        self.menusSections[indexPath.section].items.append(Menu(category: self.menusSections[indexPath.section].category))
        
        self.output.menus.accept(self.menusSections)
      }
    }
  }
  
  private func saveStore(store: Store) {
    self.output.showLoading.accept(true)
    self.storeService.saveStore(store: store)
      .subscribe(
        onNext: { [weak self] store in
          guard let self = self else { return }
          
          self.output.dismissAndGoDetail.accept(store.storeId)
          self.output.showLoading.accept(false)
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError{
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
