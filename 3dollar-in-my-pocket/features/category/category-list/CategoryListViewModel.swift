import RxSwift
import RxCocoa
import CoreLocation

class CategoryListViewModel: BaseViewModel {
  
  let input = Input()
  let ouput = Output()
  let categoryService: CategoryServiceProtocol
  let category: StoreCategory
  
  var order: CategoryOrder = .distance
  var currentLocation: CLLocation!
  var mapLocation: CLLocation? = nil
  
  struct Input {
    let currentLocation = PublishSubject<CLLocation>()
    let mapLocation = BehaviorSubject<CLLocation?>(value: nil)
    let tapOrderButton = PublishSubject<CategoryOrder>()
    let tapDistanceOrderButton = PublishSubject<Void>()
    let tapReviewOrderButton = PublishSubject<Void>()
  }
  
  struct Output {
    let stores = PublishRelay<[CategorySection]>()
  }
  
  init(category: StoreCategory, categoryService: CategoryServiceProtocol) {
    self.category = category
    self.categoryService = categoryService
    super.init()
    
    self.input.currentLocation
      .do(onNext: { [weak self] location in
        self?.currentLocation = location
      })
      .map { ($0, nil) }
      .bind(onNext: self.fetchCategoryStoresByDistance)
      .disposed(by: disposeBag)
    
    self.input.tapOrderButton
      .filter { $0 != self.order }
      .do { self.order = $0 }
      .map { order -> (order: CategoryOrder, location: (CLLocation, CLLocation?)) in
        return (order, (self.currentLocation, self.mapLocation))
      }
      .bind { [weak self] result in
        guard let self = self else { return }
        if result.0 == .distance {
          self.fetchCategoryStoresByDistance(currentLocation: result.location.0, mapLocation: result.location.1)
        } else {
          self.fetchCategoryStoresByReview(currentLocation: result.location.0, mapLocation: result.location.1)
        }
      }
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
  
  func fetchCategoryStoresByReview(
    currentLocation: CLLocation,
    mapLocation: CLLocation?
  ) {
    self.categoryService.getStoreByReview(
      category: self.category,
      currentLocation: currentLocation,
      mapLocation: mapLocation
    )
    .subscribe(
      onNext: { [weak self] categoryByReview in
        guard let self = self else { return }
        let stores = self.storesByReview(from: categoryByReview)
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
  
  private func storesByReview(from response: CategoryByReview) -> [CategorySection] {
    var categorySections: [CategorySection] = []
    let mapSection = CategorySection(
      category: self.category,
      stores: response.storeList4 + response.storeList3 + response.storeList2 + response.storeList1 + response.storeList0,
      items: [nil]
    )
    let titleSection = CategorySection(category: self.category, items: [nil])
    let review4Section = CategorySection(
      category: self.category,
      headerType: .review4,
      items: response.storeList4
    )
    let review3Section = CategorySection(
      category: self.category,
      headerType: .review3,
      items: response.storeList3
    )
    
    let review2Section = CategorySection(
      category: self.category,
      headerType: .review2,
      items: response.storeList2
    )
    
    let review1Section = CategorySection(
      category: self.category,
      headerType: .review1,
      items: response.storeList1
    )
    
    let review0Section = CategorySection(
      category: self.category,
      headerType: .review0,
      items: response.storeList0
    )
    
    categorySections.append(mapSection)
    categorySections.append(titleSection)
    if !review4Section.items.isEmpty {
      categorySections.append(review4Section)
    }
    if !review3Section.items.isEmpty {
      categorySections.append(review3Section)
    }
    if !review2Section.items.isEmpty {
      categorySections.append(review2Section)
    }
    if !review1Section.items.isEmpty {
      categorySections.append(review1Section)
    }
    if !review0Section.items.isEmpty {
      categorySections.append(review0Section)
    }
    return categorySections
  }
}
