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
    self.setupTableView()
    self.setupMap()
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
        cell.adBannerView.rootViewController = self
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
  
  private func setupTableView() {
//    self.categoryDataSource = RxTableViewSectionedReloadDataSource<CategorySection> { (dataSource, tableView, indexPath, item) in
//      if item != nil {
//        guard let cell = tableView.dequeueReusableCell(
//          withIdentifier: CategoryListStoreCell.registerId,
//          for: indexPath
//        ) as? CategoryListStoreCell else { return BaseTableViewCell() }
//        cell.bind(storeCard: dataSource.sectionModels[indexPath.section].items[indexPath.row])
//
//        return cell
//      } else {
//        guard let cell = tableView.dequeueReusableCell(
//                withIdentifier: CategoryListAdBannerCell.registerId,
//                for: indexPath
//        ) as? CategoryListAdBannerCell else { return BaseTableViewCell() }
//        #if DEBUG
//        cell.adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//        #else
//        cell.adBannerView.adUnitID = "ca-app-pub-1527951560812478/3327283605"
//        #endif
//
//        cell.adBannerView.rootViewController = self
//        cell.adBannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(cell.frame.width)
//        cell.adBannerView.delegate = self
//
//        if #available(iOS 14, *) {
//          ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//            cell.adBannerView.load(GADRequest())
//          })
//        } else {
//          cell.adBannerView.load(GADRequest())
//        }
//        return cell
//      }
//    }
//
//    self.categoryListView.storeTableView.rx.itemSelected
//      .do(onNext: { _ in
//        GA.shared.logEvent(event: .store_list_item_clicked, page: .store_list_page)
//      })
//      .map { self.categoryDataSource.sectionModels[$0.section].items[$0.row]?.id }
//      .bind(onNext: self.goToStoreDetail(storeId:))
//      .disposed(by: disposeBag)
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

extension CategoryListVC: GADBannerViewDelegate {
  /// Tells the delegate an ad request loaded an ad.
  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("adViewDidReceiveAd")
  }
  
  /// Tells the delegate that a full-screen view will be presented in response
  /// to the user clicking on an ad.
  func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
    print("adViewWillPresentScreen")
  }
  
  /// Tells the delegate that the full-screen view will be dismissed.
  func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
    print("adViewWillDismissScreen")
  }
  
  /// Tells the delegate that the full-screen view has been dismissed.
  func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
    print("adViewDidDismissScreen")
  }
  
  /// Tells the delegate that a user click will open another app (such as
  /// the App Store), backgrounding the current app.
  func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    print("adViewWillLeaveApplication")
  }
}
