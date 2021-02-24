import RxSwift
import RxCocoa
import CoreLocation

class CategoryListViewModel: BaseViewModel {
  
  let input = Input()
  let ouput = Output()
  let categoryService: CategoryServiceProtocol
  let category: StoreCategory
  
  struct Input {
    let currentLocation = PublishSubject<CLLocation>()
    let mapLocation = BehaviorSubject<CLLocation?>(value: nil)
  }
  
  struct Output {
    let stores = PublishRelay<[CategorySection]>()
  }
  
  init(category: StoreCategory, categoryService: CategoryServiceProtocol) {
    self.category = category
    self.categoryService = categoryService
    super.init()
    
    self.input.currentLocation
      .map { ($0, nil) }
      .bind(onNext: self.fetchCategoryStoresByDistance)
      .disposed(by: disposeBag)
  }
  
  func fetchCategoryStoresByDistance(
    currentLocation: CLLocation,
    mapLocation: CLLocation?
  ) {
    self.categoryService.getStoreByDistance(
      category: self.category,
      currentLocation: currentLocation,
      mapLocation: mapLocation
    ).subscribe(
      onNext: { [weak self] categoryByDistance in
        guard let self = self else { return }
        let stores = self.storesByDistance(from: categoryByDistance)
        self.ouput.stores.accept(stores)
      },
      onError: { [weak self] error in
        guard let self = self else { return }
        if let httpError = error as? HTTPError {
          self.httpErrorAlert.accept(httpError)
        }
      }
    )
    .disposed(by: disposeBag)
  }
  
  private func storesByDistance(from response: CategoryByDistance) -> [CategorySection] {
    var categorySections: [CategorySection] = []
    let mapSection = CategorySection(
      category: self.category,
      stores: response.storeList50 + response.storeList100 + response.storeList500 + response.storeList1000 + response.storeListOver1000,
      items: [nil]
    )
    let titleSection = CategorySection(category: self.category, items: [nil])
    let distanceSection1 = CategorySection(
      category: self.category,
      headerType: .distance50,
      items: response.storeList50
    )
    let distanceSection2 = CategorySection(
      category: self.category,
      headerType: .distance100,
      items: response.storeList100
    )
    
    let distanceSection3 = CategorySection(
      category: self.category,
      headerType: .distance500,
      items: response.storeList500
    )
    
    let distanceSection4 = CategorySection(
      category: self.category,
      headerType: .distance1000,
      items: response.storeList1000
    )
    
    let distanceSection5 = CategorySection(
      category: self.category,
      headerType: .distanceOver1000,
      items: response.storeListOver1000
    )
    
    categorySections.append(mapSection)
    categorySections.append(titleSection)
    if !distanceSection1.items.isEmpty {
      categorySections.append(distanceSection1)
    }
    if !distanceSection2.items.isEmpty {
      categorySections.append(distanceSection2)
    }
    if !distanceSection3.items.isEmpty {
      categorySections.append(distanceSection3)
    }
    if !distanceSection4.items.isEmpty {
      categorySections.append(distanceSection4)
    }
    if !distanceSection5.items.isEmpty {
      categorySections.append(distanceSection5)
    }
    return categorySections
  }
}
