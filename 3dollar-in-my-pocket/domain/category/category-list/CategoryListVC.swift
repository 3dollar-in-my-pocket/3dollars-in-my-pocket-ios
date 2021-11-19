import UIKit
import RxSwift
import RxDataSources
import NMapsMap
import GoogleMobileAds
import FirebaseCrashlytics
import AppTrackingTransparency
import AdSupport

final class CategoryListVC: BaseVC, CategoryListCoordinator {
  
  private let categoryListView = CategoryListView()
  private let viewModel: CategoryListViewModel
  private weak var coordinator: CategoryListCoordinator?
  private var markers: [NMFMarker] = []
  
  
  init(category: StoreCategory) {
    self.viewModel = CategoryListViewModel(
      category: category,
      storeService: StoreService(),
      locationManager: LocationManager.shared
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(category: StoreCategory) -> CategoryListVC {
    return CategoryListVC(category: category)
  }
  
  override func loadView() {
    self.view = self.categoryListView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.coordinator = self
    self.setupMap()
    self.categoryListView.adBannerView.rootViewController = self
    self.viewModel.input.viewDidLoad.onNext(())
  }
  
  override func bindViewModelInput() {
    self.categoryListView.currentLocationButton.rx.tap
      .bind(to: self.viewModel.input.tapCurrentLocationButton)
      .disposed(by: self.disposeBag)
    
    self.categoryListView.orderFilterButton.rx.orderType
      .bind(to: self.viewModel.input.tapOrderButton)
      .disposed(by: self.disposeBag)
    
    self.categoryListView.certificatedButton.rx.isCertificated
      .bind(to: self.viewModel.input.tapCertificatedButton)
      .disposed(by: self.disposeBag)
    
    self.categoryListView.storeTableView.rx.itemSelected
      .map { $0.row }
      .bind(to: self.viewModel.input.tapStore)
      .disposed(by: self.disposeBag)
  }
  
  override func bindViewModelOutput() {
    self.viewModel.ouput.category
      .asDriver(onErrorJustReturn: .BUNGEOPPANG)
      .drive { [weak self] category in
        self?.categoryListView.bind(category: category)
      }
      .disposed(by: self.disposeBag)
    
    self.viewModel.ouput.stores
      .do(onNext: { [weak self] stores in
        self?.setMarkders(stores: stores)
        self?.categoryListView.bind(stores: stores)
      })
      .bind(to: self.categoryListView.storeTableView.rx.items(
        cellIdentifier: CategoryListStoreCell.registerId,
        cellType: CategoryListStoreCell.self
      )) { _, store, cell in
        cell.bind(store: store)
      }
      .disposed(by: self.disposeBag)
    
    self.viewModel.ouput.moveCamera
      .asDriver(onErrorJustReturn: CLLocation(latitude: 0, longitude: 0))
      .drive { [weak self] location in
        self?.categoryListView.moveCemra(location: location)
      }
      .disposed(by: self.disposeBag)
    
    self.viewModel.ouput.pushStoreDetail
      .asDriver(onErrorJustReturn: 0)
      .drive { [weak self] storeId in
        self?.coordinator?.pushStoreDetail(storeId: storeId)
      }
      .disposed(by: self.disposeBag)
  }
  
  override func bindEvent() {
    self.categoryListView.backButton.rx.tap
      .asDriver()
      .drive(onNext: { [weak self] _ in
        self?.coordinator?.popup()
      })
      .disposed(by: self.disposeBag)
  }
  
  private func setupMap() {
    self.categoryListView.mapView.addCameraDelegate(delegate: self)
  }
  
  private func setMarkders(stores: [Store?]) {
    for marker in self.markers {
      marker.mapView = nil
    }
    
    for store in stores {
      if let store = store {
        let marker = NMFMarker()
        
        marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
        marker.iconImage = NMFOverlayImage(name: "ic_marker_store_on")
        marker.mapView = self.categoryListView.mapView
        self.markers.append(marker)
      }
    }
  }
}

extension CategoryListVC: NMFMapViewCameraDelegate {
  
  func mapViewCameraIdle(_ mapView: NMFMapView) {
    let mapLocation = CLLocation(
      latitude: mapView.cameraPosition.target.lat,
      longitude: mapView.cameraPosition.target.lng
    )
    
    self.viewModel.input.changeMapLocation.onNext(mapLocation)
  }
}
