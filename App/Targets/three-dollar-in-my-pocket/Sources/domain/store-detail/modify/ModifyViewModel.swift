import Foundation

import RxSwift
import RxCocoa

class ModifyViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  
  let storeService: StoreServiceProtocol
  let mapService: MapServiceProtocol
  let globalState: GlobalState
  var store: Store
  
  var location: (Double, Double)
  var appearenceDay: [WeekDay] = []
  var categories: [StreetFoodStoreCategory?] = [nil]
  var menuSections: [MenuSection] = []
  var paymentType: [PaymentType] = []
  
  struct Input {
    let storeName = PublishSubject<String>()
    let tapEdit = PublishSubject<Void>()
    let editLocation = PublishSubject<(Double, Double)>()
    let tapDay = PublishSubject<WeekDay>()
    let tapStoreType = PublishSubject<StreetFoodStoreType?>()
    let tapPaymentType = PublishSubject<PaymentType>()
    let tapAddCategory = PublishSubject<Void>()
    let tapCategoryDelete = PublishSubject<Int>()
    let addCategories = PublishSubject<[StreetFoodStoreCategory]>()
    let deleteAllCategories = PublishSubject<Void>()
    let menuName = PublishSubject<(IndexPath, String)>()
    let menuPrice = PublishSubject<(IndexPath, String)>()
    let deleteCategory = PublishSubject<Int>()
    let tapModify = PublishSubject<Void>()
  }
  
  struct Output {
    let address = PublishRelay<String>()
    let moveCamera = PublishRelay<(Double, Double)>()
    let goToEditAddress = PublishRelay<Store>()
    let storeNameIsEmpty = PublishRelay<Bool>()
    let selectType = PublishRelay<StreetFoodStoreType?>()
    let selectPaymentType = PublishRelay<[PaymentType]>()
    let selectDays = PublishRelay<[WeekDay]>()
    let categories = PublishRelay<[StreetFoodStoreCategory?]>()
    let showCategoryDialog = PublishRelay<[StreetFoodStoreCategory?]>()
    let menus = PublishRelay<[MenuSection]>()
    let fetchMenuTableViewHeight = PublishRelay<Void>()
    let registerButtonIsEnable = PublishRelay<Bool>()
    let popVC = PublishRelay<Void>()
    let showLoading = PublishRelay<Bool>()
  }
  
  init(
    store: Store,
    storeService: StoreServiceProtocol,
    mapService: MapServiceProtocol,
    globalState: GlobalState
  ) {
    self.store = store
    self.storeService = storeService
    self.mapService = mapService
    self.globalState = globalState
    self.location = (store.latitude, store.longitude)
    self.appearenceDay = store.appearanceDays
    self.paymentType = store.paymentMethods
    self.categories = [nil] + store.categories
    super.init()
    
    self.menuSections = self.menuSectionFromMenus(
      categories: store.categories,
      menus: store.menus
    )
    
    self.input.tapEdit
      .map { self.store }
      .bind(to: self.output.goToEditAddress)
      .disposed(by: disposeBag)
    
    self.input.editLocation
      .do(onNext: { (latitude, longitude) in
        self.location = (latitude, longitude)
      })
      .bind(to: self.output.moveCamera)
      .disposed(by: disposeBag)
    
    self.input.storeName
      .map { $0.isEmpty }
      .bind(to: self.output.storeNameIsEmpty)
      .disposed(by: disposeBag)
    
    self.input.storeName
      .map { !$0.isEmpty && !self.categories.compactMap { $0 }.isEmpty }
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
      .map { self.categories }
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
    
    self.input.tapModify
      .withLatestFrom(Observable.combineLatest(self.input.storeName, self.input.tapStoreType))
      .map { Store(
        id: self.store.storeId,
        appearanceDays: self.appearenceDay,
        categories: self.categories.compactMap { $0 },
        latitude: self.location.0,
        longitude: self.location.1,
        menuSections: self.menuSections,
        paymentType: self.paymentType,
        storeName: $0.0,
        storeType: $0.1
      )}
      .bind(onNext: self.updateStroe(store:))
      .disposed(by: disposeBag)
    
    self.output.categories
      .withLatestFrom(self.input.storeName) { !$0.compactMap { $0 }.isEmpty && !$1.isEmpty }
      .bind(to: self.output.registerButtonIsEnable)
      .disposed(by: disposeBag)
  }
  
  func fetchStore() {
    self.input.storeName.onNext(self.store.storeName)
    self.input.tapStoreType.onNext(self.store.storeType)
    self.output.moveCamera.accept((self.store.latitude, self.store.longitude))
    self.output.selectPaymentType.accept(self.store.paymentMethods)
    self.output.selectDays.accept(self.store.appearanceDays)
    self.output.categories.accept(self.categories)
    self.output.menus.accept(self.menuSections)
    self.getAddressFromLocation(lat: self.location.0, lng: self.location.1)
  }
  
  private func menuSectionFromMenus(categories: [StreetFoodStoreCategory], menus: [Menu]) -> [MenuSection] {
    var menuSections: [MenuSection] = []
    
    for category in categories {
      var menuSection = MenuSection(category: category, items: [])
        for menu in menus where menu.category == category {
            menuSection.items.append(menu)
      }
      menuSection.items.append(Menu(category: category))
      menuSections.append(menuSection)
    }
    
    return menuSections
  }
  
  private func categoryFromMenus(menus: [Menu]) -> [StreetFoodStoreCategory?] {
    var categories: [StreetFoodStoreCategory?] = [nil]
    
    for menu in menus where !categories.contains(menu.category) {
        categories.append(menu.category)
    }
    return categories
  }
  
  private func getAddressFromLocation(lat: Double, lng: Double) {
    self.mapService.getAddressFromLocation(latitude: lat, longitude: lng)
      .subscribe(
        onNext: self.output.address.accept,
        onError: { error in
          if let httpError = error as? HTTPError {
            self.httpErrorAlert.accept(httpError)
          } else if let error = error as? CommonError {
            let alertContent = AlertContent(title: nil, message: error.description)
            
            self.showSystemAlert.accept(alertContent)
          }
        }
      )
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
  
  private func onAddCategory(categories: [StreetFoodStoreCategory]) {
    var newMenuSection: [MenuSection] = []
    
    for category in categories {
      if self.categories.contains(category) {
        for menuSection in self.menuSections where menuSection.category == category {
            newMenuSection.append(menuSection)
            break
        }
      } else {
        newMenuSection.append(MenuSection(category: category, items: [Menu(category: category)]))
      }
    }
    
    self.menuSections = newMenuSection
    self.categories = [nil] + categories
    self.output.categories.accept(self.categories)
    self.output.menus.accept(self.menuSections)
  }
  
  private func onTapDeleteAllCategories() {
    self.categories = [nil]
    self.menuSections = []
    
    self.output.categories.accept(categories)
    self.output.menus.accept(menuSections)
  }
  
  private func onEditMenuName(indexPath: IndexPath, name: String) {
    if !name.isEmpty {
      self.menuSections[indexPath.section].items[indexPath.row].name = name
      if self.menuSections[indexPath.section].items.count == indexPath.row + 1 {
        self.menuSections[indexPath.section].items.append(
            Menu(category: self.menuSections[indexPath.section].items[indexPath.row].category)
        )
        
        self.output.menus.accept(self.menuSections)
      }
    } else {
      self.menuSections[indexPath.section].items[indexPath.row].name = ""
    }
  }
  
  private func onEditMenuPrice(indexPath: IndexPath, price: String) {
    if !price.isEmpty {
      self.menuSections[indexPath.section].items[indexPath.row].price = price
      if self.menuSections[indexPath.section].items.count == indexPath.row + 1 {
        self.menuSections[indexPath.section].items.append(
            Menu(category: self.menuSections[indexPath.section].items[indexPath.row].category)
        )
        self.output.menus.accept(self.menuSections)
      }
    } else {
      self.menuSections[indexPath.section].items[indexPath.row].price = ""
    }
  }
  
  private func deleteCategory(index: Int) {
    if self.categories.count >= index + 1 {
      self.categories.remove(at: index + 1)
      Observable.just(self.categories)
        .bind(to: self.output.categories)
        .disposed(by: disposeBag)
    }
    
    self.menuSections.remove(at: index)
    Observable.just(self.menuSections)
      .bind(to: self.output.menus)
      .disposed(by: disposeBag)
  }
  
  private func updateStroe(store: Store) {
    self.output.showLoading.accept(true)
    self.storeService.updateStore(storeId: store.storeId, updateStoreRequest: .init(store: store))
      .subscribe { [weak self] _ in
        guard let self = self else { return }
        
        self.output.showLoading.accept(false)
        self.globalState.updateStore.onNext(store)
        self.output.popVC.accept(())
      } onError: { [weak self] error in
        guard let self = self else { return }
        if let httpError = error as? HTTPError {
          self.httpErrorAlert.accept(httpError)
        }
        if let commonError = error as? CommonError {
          let alertContent = AlertContent(title: nil, message: commonError.description)
          
          self.showSystemAlert.accept(alertContent)
        }
        
        self.output.showLoading.accept(false)
      }
      .disposed(by: disposeBag)
  }
}
