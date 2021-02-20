import RxSwift
import RxCocoa

class HomeViewModel: BaseViewModel {
  
  let input = Input()
  let output = Output()
  let storeService: StoreServiceProtocol
  
  var selectedIndex: Int = 0
  var stores: [StoreCard] = []
  
  struct Input {
    let location = PublishSubject<(Double, Double)>()
    let selectStore = PublishSubject<Int>()
    let tapStore = PublishSubject<Int>()
    let deselectCurrentStore = PublishSubject<Void>()
  }
  
  struct Output {
    let stores = PublishRelay<[StoreCard]>()
    let scrollToIndex = PublishRelay<IndexPath>()
    let setSelectStore = PublishRelay<(IndexPath, Bool)>()
    let selectMarker = PublishRelay<(Int, [StoreCard])>()
    let goToDetail = PublishRelay<Int>()
    let showLoading = PublishRelay<Bool>()
  }
  
  
  init(storeService: StoreServiceProtocol) {
    self.storeService = storeService
    super.init()
    
    self.input.location
      .bind(onNext: self.fetchNearestStores)
      .disposed(by: disposeBag)
    
    self.input.selectStore
      .bind(onNext: self.onSelectStore(index:))
      .disposed(by: disposeBag)
    
    self.input.tapStore
      .bind(onNext: self.onTapStore(index:))
      .disposed(by: disposeBag)
    
    self.input.deselectCurrentStore
      .bind(onNext: self.deselectStore)
      .disposed(by: disposeBag)
  }
  
  func fetchNearestStores(latitude: Double, longitude: Double) {
    self.output.showLoading.accept(true)
    self.storeService.getStoreOrderByNearest(latitude: latitude, longitude: longitude)
      .subscribe(
        onNext: { [weak self] stores in
          guard let self = self else { return }
          self.stores = stores
          self.output.stores.accept(stores)
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.onSelectStore(index: 0)
          }
          self.output.showLoading.accept(false)
        },
        onError: { [weak self] error in
          guard let self = self else { return }
          if let httpError = error as? HTTPError{
            self.httpErrorAlert.accept(httpError)
          }
          self.output.showLoading.accept(false)
        }
      )
      .disposed(by: disposeBag)
  }
  
  private func onSelectStore(index: Int){
    self.output.scrollToIndex.accept(IndexPath(row: index, section: 0))
    self.output.selectMarker.accept((index, self.stores))
    self.output.setSelectStore.accept((IndexPath(row: self.selectedIndex, section: 0), false))
    self.output.setSelectStore.accept((IndexPath(row: index, section: 0), true))
    self.selectedIndex = index
  }
  
  private func onTapStore(index: Int) {
    if selectedIndex == index {
      GA.shared.logEvent(event: .store_card_button_clicked, page: .home_page)
      self.output.goToDetail.accept(self.stores[index].id)
    } else {
      self.output.scrollToIndex.accept(IndexPath(row: index, section: 0))
      self.output.selectMarker.accept((index, self.stores))
      self.output.setSelectStore.accept((IndexPath(row: self.selectedIndex, section: 0), false))
      self.output.setSelectStore.accept((IndexPath(row: index, section: 0), true))
      self.selectedIndex = index
    }
  }
  
  private func deselectStore() {
    let indexPath = IndexPath(row: self.selectedIndex, section: 0)
    
    self.output.setSelectStore.accept((indexPath, false))
  }
}
