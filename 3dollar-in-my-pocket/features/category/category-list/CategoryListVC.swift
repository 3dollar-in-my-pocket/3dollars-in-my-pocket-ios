import UIKit
import RxSwift
import RxDataSources
import NMapsMap
import GoogleMobileAds
import FirebaseCrashlytics
import AppTrackingTransparency
import AdSupport

class CategoryListVC: BaseVC {
  
  private lazy var categoryListView = CategoryListView(frame: self.view.frame)
  private let locationManager = CLLocationManager()
  private let viewModel: CategoryListViewModel
  private let category: StoreCategory
  
  private var myLocationFlag = false
  private var markers: [NMFMarker] = []
  var categoryDataSource: RxTableViewSectionedReloadDataSource<CategorySection>!
  
  
  init(category: StoreCategory) {
    self.category = category
    self.viewModel = CategoryListViewModel(
      category: category,
      categoryService: CategoryService()
    )
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  static func instance(category: StoreCategory) -> CategoryListVC {
    return CategoryListVC(category: category)
  }
  
  override func viewDidLoad() {
    self.setupTableView()
    
    super.viewDidLoad()
    
    view = categoryListView
    self.setupLocationManager()
//    self.loadAdBanner()
    self.categoryListView.setCategoryTitle(category: self.category)
  }
  
  override func bindViewModel() {
    // Bind output
    self.viewModel.ouput.stores
      .bind(to: self.categoryListView.storeTableView.rx.items(dataSource: self.categoryDataSource))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    categoryListView.backButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .back_button_clicked, page: .store_list_page)
      })
      .bind(onNext: self.popVC)
      .disposed(by: disposeBag)
  }
  
  private func setupTableView() {
    self.categoryListView.storeTableView.register(
      CategoryListMapCell.self,
      forCellReuseIdentifier: CategoryListMapCell.registerId
    )
    
    self.categoryListView.storeTableView.register(
      CategoryListTitleCell.self,
      forCellReuseIdentifier: CategoryListTitleCell.registerId
    )
    
    self.categoryListView.storeTableView.register(
      CategoryListStoreCell.self,
      forCellReuseIdentifier: CategoryListStoreCell.registerId
    )
    
    self.categoryListView.storeTableView.rx
      .setDelegate(self)
      .disposed(by: disposeBag)
    
    self.categoryDataSource = RxTableViewSectionedReloadDataSource<CategorySection> { (dataSource, tableView, indexPath, item) in
      switch indexPath.section {
      case 0:
        guard let cell = tableView.dequeueReusableCell(
          withIdentifier: CategoryListMapCell.registerId,
          for: indexPath
        ) as? CategoryListMapCell else { return BaseTableViewCell() }
        
        cell.mapView.removeCameraDelegate(delegate: self)
        cell.mapView.positionMode = .direction
        cell.mapView.addCameraDelegate(delegate: self)
        cell.currentLocationButton.rx.tap
          .do(onNext: { _ in
            self.myLocationFlag = true
          })
          .observeOn(MainScheduler.instance)
          .bind(onNext: self.setupLocationManager)
          .disposed(by: cell.disposeBag)
        
        for marker in self.markers {
          marker.mapView = nil
        }
        
        for store in dataSource.sectionModels[indexPath.section].stores {
          let marker = NMFMarker()
          marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
          marker.iconImage = NMFOverlayImage(name: "ic_marker_store_on")
          marker.mapView = cell.mapView
          self.markers.append(marker)
        }
        
        return cell
      case 1:
        guard let cell = tableView.dequeueReusableCell(
          withIdentifier: CategoryListTitleCell.registerId,
          for: indexPath
        ) as? CategoryListTitleCell else { return BaseTableViewCell() }
        
        cell.distanceOrderButton.rx.tap
          .map { CategoryOrder.distance }
          .do(onNext: cell.onTapOrderButton)
          .do(onNext: { _ in
            GA.shared.logEvent(event: .order_by_rating_button_list, page: .store_list_page)
          })
          .bind(to: self.viewModel.input.tapOrderButton)
          .disposed(by: cell.disposeBag)
        
        cell.reviewOrderButton.rx.tap
          .map { CategoryOrder.review }
          .do(onNext: cell.onTapOrderButton)
          .do(onNext: { _ in
            GA.shared.logEvent(event: .order_by_rating_button_list, page: .store_list_page)
          })
          .bind(to: self.viewModel.input.tapOrderButton)
          .disposed(by: cell.disposeBag)
        cell.bind(category: dataSource.sectionModels[indexPath.section].category)
        return cell
      default:
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CategoryListStoreCell.registerId,
                for: indexPath
        ) as? CategoryListStoreCell else { return BaseTableViewCell() }
        cell.bind(storeCard: dataSource.sectionModels[indexPath.section].items[indexPath.row])
        return cell
      }
    }
    
    self.categoryListView.storeTableView.rx.itemSelected
      .filter { $0.section > 1 }
      .do(onNext: { _ in
        GA.shared.logEvent(event: .store_list_item_clicked, page: .store_list_page)
      })
      .map { self.categoryDataSource.sectionModels[$0.section].items[$0.row]?.id }
      .bind(onNext: self.goToStoreDetail(storeId:))
      .disposed(by: disposeBag)
  }
  
  private func setupLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  private func popVC() {
    self.navigationController?.popViewController(animated: true)
  }
  
  private func goToStoreDetail(storeId: Int?) {
    if let storeId = storeId {
      self.navigationController?.pushViewController(
        StoreDetailVC.instance(storeId: storeId),
        animated: true
      )
    }
  }
  
//  private func loadAdBanner() {
//    #if DEBUG
//    self.categoryListView.adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
//    #else
//    self.categoryListView.adBannerView.adUnitID = "ca-app-pub-1527951560812478/3327283605"
//    #endif
//
//    self.categoryListView.adBannerView.rootViewController = self
//    self.categoryListView.adBannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(self.view.frame.width)
//    self.categoryListView.adBannerView.delegate = self
//
//    if #available(iOS 14, *) {
//      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//        self.categoryListView.adBannerView.load(GADRequest())
//      })
//    } else {
//      self.categoryListView.adBannerView.load(GADRequest())
//    }
//  }
//
}

extension CategoryListVC: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch section {
    case 0, 1:
      return UIView(frame: .zero)
    default:
      let headerView = CategoryListHeaderView()
      
      headerView.bind(type: self.categoryDataSource.sectionModels[section].headerType)
      return headerView
    }
  }
}

//MARK: NMFMapViewCameraDelegate
extension CategoryListVC: NMFMapViewCameraDelegate {
  
  func mapViewCameraIdle(_ mapView: NMFMapView) {
    let mapLocation = CLLocation(
      latitude: mapView.cameraPosition.target.lat,
      longitude: mapView.cameraPosition.target.lng
    )
    
    self.viewModel.input.mapLocation.onNext(mapLocation)
  }
}

extension CategoryListVC: CLLocationManagerDelegate {
  
  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    if !locations.isEmpty {
      let lastLocation = locations.last
      let location = CLLocation(
        latitude: lastLocation!.coordinate.latitude,
        longitude: lastLocation!.coordinate.longitude
      )
      let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(
        lat: lastLocation!.coordinate.latitude,
        lng: lastLocation!.coordinate.longitude
      ))
      cameraUpdate.animation = .easeIn
      
      if !self.myLocationFlag {
        self.viewModel.input.currentLocation.onNext(location)
        self.myLocationFlag = false
      } else {
        guard let mapCell = self.categoryListView.storeTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CategoryListMapCell else { return }
        
        mapCell.mapView.moveCamera(cameraUpdate)
      }
    }
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if let error = error as? CLError {
      switch error.code {
      case .denied:
        AlertUtils.show(
          controller: self,
          title: "error_location_permission_denied_title".localized,
          message: "error_location_permission_denied_message".localized
        )
      case .locationUnknown:
        AlertUtils.show(
          controller: self,
          title: "error_location_unknown_title".localized,
          message: "error_location_unknown_message".localized
        )
      default:
        AlertUtils.show(
          controller: self,
          title: "error_location_default_title".localized,
          message: "error_location_default_message".localized
        )
        Crashlytics.crashlytics().log("location Manager Error(error code: \(error.code.rawValue)")
      }
    }
  }
}

extension CategoryListVC: GADBannerViewDelegate {
  /// Tells the delegate an ad request loaded an ad.
  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("adViewDidReceiveAd")
  }
  
  /// Tells the delegate an ad request failed.
  func adView(_ bannerView: GADBannerView,
              didFailToReceiveAdWithError error: GADRequestError) {
    print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
  }
  
  /// Tells the delegate that a full-screen view will be presented in response
  /// to the user clicking on an ad.
  func adViewWillPresentScreen(_ bannerView: GADBannerView) {
    print("adViewWillPresentScreen")
  }
  
  /// Tells the delegate that the full-screen view will be dismissed.
  func adViewWillDismissScreen(_ bannerView: GADBannerView) {
    print("adViewWillDismissScreen")
  }
  
  /// Tells the delegate that the full-screen view has been dismissed.
  func adViewDidDismissScreen(_ bannerView: GADBannerView) {
    print("adViewDidDismissScreen")
  }
  
  /// Tells the delegate that a user click will open another app (such as
  /// the App Store), backgrounding the current app.
  func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
    print("adViewWillLeaveApplication")
  }
}
