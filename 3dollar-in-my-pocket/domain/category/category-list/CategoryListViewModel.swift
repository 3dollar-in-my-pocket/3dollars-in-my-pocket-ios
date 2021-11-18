import RxSwift
import RxCocoa
import CoreLocation

final class CategoryListViewModel: BaseViewModel {
  
  struct Input {
    let viewDidLoad = PublishSubject<Void>()
    let tapCurrentLocationButton = PublishSubject<Void>()
    let changeMapLocation = PublishSubject<CLLocation>()
    let tapOrderButton = PublishSubject<StoreOrder>()
    let tapCertificatedButton = PublishSubject<Bool>()
    let tapStore = PublishSubject<Int>()
  }
  
  struct Output {
    let category = PublishRelay<StoreCategory>()
    let stores = PublishRelay<[Store]>()
    let moveCamera = PublishRelay<CLLocation>()
    let pushStoreDetail = PublishRelay<Int>()
  }
  
  struct Model {
    let category: StoreCategory
    var stores: [Store] = []
    var mapLocation: CLLocation?
    var currentLocation: CLLocation?
    var isOnlyCertificated = false
    var orderType: StoreOrder = .distance
  }
  
  let input = Input()
  let ouput = Output()
  var model: Model
  let storeService: StoreServiceProtocol
  let locationManager: LocationManagerProtocol
  
  
  init(
    category: StoreCategory,
    storeService: StoreServiceProtocol,
    locationManager: LocationManagerProtocol
  ) {
    self.model = Model(category: category)
    self.storeService = storeService
    self.locationManager = locationManager
    
    super.init()
  }
  
  override func bind() {
    self.input.viewDidLoad
      .flatMap { self.locationManager.getCurrentLocation() }
      .do(onNext: { [weak self] currentLocation in
        self?.model.currentLocation = currentLocation
      })
      .bind(onNext: { [weak self] currentLocation in
        guard let self = self else { return }
        
        self.fetchStores(
          category: self.model.category,
          currentLocation: currentLocation,
          mapLocation: currentLocation,
          distance: 1000,
          orderType: self.model.orderType
        )
        self.ouput.category.accept(self.model.category)
      })
      .disposed(by: self.disposeBag)
    
    self.input.tapCurrentLocationButton
      .flatMap { self.locationManager.getCurrentLocation() }
      .do(onNext: { [weak self] currentLocation in
        self?.model.currentLocation = currentLocation
      })
      .bind(to: self.ouput.moveCamera)
      .disposed(by: self.disposeBag)
    
    self.input.changeMapLocation
      .do { [weak self] location in
        self?.model.mapLocation = location
      }
      .bind { [weak self] mapLocation in
        guard let self = self,
              let currentLocation = self.model.currentLocation,
              let mapLocation = self.model.mapLocation else { return }
        
        self.fetchStores(
          category: self.model.category,
          currentLocation: currentLocation,
          mapLocation: mapLocation,
          distance: 1000,
          orderType: self.model.orderType
        )
      }
      .disposed(by: self.disposeBag)
    
    self.input.tapOrderButton
      .do { [weak self] order in
        self?.model.orderType = order
      }
      .bind { [weak self] _ in
        guard let self = self,
              let currentLocation = self.model.currentLocation,
              let mapLocation = self.model.mapLocation else { return }
        
        self.fetchStores(
          category: self.model.category,
          currentLocation: currentLocation,
          mapLocation: mapLocation,
          distance: 1000,
          orderType: self.model.orderType
        )
      }
      .disposed(by: self.disposeBag)
    
    self.input.tapCertificatedButton
      .do(onNext: { [weak self] isOnlyCertificated in
        self?.model.isOnlyCertificated = isOnlyCertificated
      })
      .bind { [weak self] isCertificated in
        guard let self = self else { return }
        
        if self.model.isOnlyCertificated {
          let certificatedStores = self.model.stores.filter { $0.isCertificated == true }
          
          self.ouput.stores.accept(certificatedStores)
        } else {
          self.ouput.stores.accept(self.model.stores)
        }
      }
      .disposed(by: self.disposeBag)
    
    self.input.tapStore
      .withLatestFrom(self.ouput.stores) { $1[$0].storeId }
      .bind(to: self.ouput.pushStoreDetail)
      .disposed(by: self.disposeBag)
  }
  
  private func fetchStores(
    category: StoreCategory,
    currentLocation: CLLocation,
    mapLocation: CLLocation,
    distance: Double,
    orderType: StoreOrder
  ) {
    self.storeService.searchNearStores(
      currentLocation: currentLocation,
      mapLocation: mapLocation,
      distance: distance,
      category: category,
      orderType: orderType
    ).subscribe { [weak self] stores in
      guard let self = self else { return }
      self.model.stores = stores
      
      if self.model.isOnlyCertificated {
        let certificatedStores = stores.filter { $0.isCertificated }
        
        self.ouput.stores.accept(certificatedStores)
      } else {
        self.ouput.stores.accept(stores)
      }
    } onError: { [weak self] error in
      self?.showErrorAlert.accept(error)
    }
    .disposed(by: self.disposeBag)
  }
}
