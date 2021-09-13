import UIKit
import RxSwift
import NMapsMap
import FirebaseCrashlytics

class HomeVC: BaseVC {
  
  private let homeView = HomeView()
  private let viewModel = HomeViewModel(
    storeService: StoreService(),
    mapService: MapService(),
    userDefaults: UserDefaultsUtil()
  )
  
  var mapAnimatedFlag = false
  var previousOffset: CGFloat = 0
  var markers: [NMFMarker] = []
  let transition = SearchTransition()
  let locationManager = CLLocationManager()
  
  static func instance() -> UINavigationController {
    let homeVC = HomeVC(nibName: nil, bundle: nil).then {
      $0.tabBarItem = UITabBarItem(
        title: nil,
        image: R.image.ic_home(),
        tag: TabBarTag.home.rawValue
      )
    }
    
    return UINavigationController(rootViewController: homeVC).then {
      $0.isNavigationBarHidden = true
      $0.interactivePopGestureRecognizer?.delegate = nil
    }
  }
  
  deinit {
    self.locationManager.stopUpdatingLocation()
  }
  
  override func loadView() {
    self.view = self.homeView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.initilizeShopCollectionView()
    self.initilizeLocationManager()
  }
  
  override func bindViewModel() {
    // Bind input
    self.homeView.researchButton.rx.tap
      .bind(to: self.viewModel.input.tapResearch)
      .disposed(by: disposeBag)
    
    // Bind output
    self.viewModel.output.address
      .bind(to: self.homeView.addressButton.rx.title(for: .normal))
      .disposed(by: disposeBag)
    
    self.viewModel.output.stores
      .bind(to: homeView.storeCollectionView.rx.items(
        cellIdentifier: StoreCell.registerId,
        cellType: StoreCell.self
      )) { _, store, cell in
        cell.bind(store: store)
      }.disposed(by: disposeBag)
    
    self.viewModel.output.isHiddenResearchButton
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.homeView.isHiddenResearchButton(isHidden:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.isHiddenEmptyCell
      .bind(to: self.homeView.emptyCell.rx.isHidden)
      .disposed(by: disposeBag)
    
    self.viewModel.output.scrollToIndex
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.homeView.scrollToIndex(index:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.setSelectStore
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.homeView.setSelectStore)
      .disposed(by: disposeBag)
    
    self.viewModel.output.selectMarker
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.selectMarker)
      .disposed(by: disposeBag)
    
    self.viewModel.output.goToDetail
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToDetail(storeId:))
      .disposed(by: disposeBag)
    
    self.viewModel.output.showLoading
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showRootLoading(isShow:))
      .disposed(by: disposeBag)
    
    self.viewModel.showSystemAlert
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showSystemAlert(alert:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.homeView.addressButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .search_button_clicked, page: .home_page)
      })
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.showSearchAddress)
      .disposed(by: disposeBag)
    
    self.homeView.currentLocationButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .current_location_button_clicked, page: .home_page)
      })
      .observeOn(MainScheduler.instance)
      .bind { [weak self] in
        guard let self = self else { return }
        self.mapAnimatedFlag = true
        self.locationManager.startUpdatingLocation()
      }
      .disposed(by: disposeBag)
    
    self.homeView.tossButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .toss_button_clicked, page: .home_page)
      })
      .observeOn(MainScheduler.instance)
      .bind(onNext: self.goToToss)
      .disposed(by: disposeBag)
  }
  
  func goToDetail(storeId: Int) {
    let storeDetailVC = StoreDetailVC.instance(storeId: storeId).then {
      $0.delegate = self
    }
    self.navigationController?.pushViewController(
      storeDetailVC,
      animated: true
    )
  }
  
  private func initilizeShopCollectionView() {
    self.homeView.storeCollectionView.delegate = self
  }
  
  private func initilizeNaverMap() {
    self.homeView.mapView.positionMode = .direction
    self.homeView.mapView.zoomLevel = 15
    self.homeView.mapView.addCameraDelegate(delegate: self)
  }
  
  private func selectMarker(selectedIndex: Int, stores: [StoreInfoResponse]) {
    self.clearMarker()
    
    for index in stores.indices {
      let store = stores[index]
      let marker = NMFMarker()
      
      marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
      if index == selectedIndex {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: store.latitude, lng: store.longitude))
        cameraUpdate.animation = .easeIn
        self.homeView.mapView.moveCamera(cameraUpdate)
        marker.iconImage = NMFOverlayImage(name: "ic_marker")
        marker.width = 30
        marker.height = 40
      } else {
        marker.iconImage = NMFOverlayImage(name: "ic_marker_store_off")
        marker.width = 16
        marker.height = 16
      }
      marker.mapView = self.homeView.mapView
      marker.touchHandler =  { [weak self] _ in
        guard let self = self else { return false }
        self.viewModel.input.selectStore.onNext(index)
        return true
      }
      self.markers.append(marker)
    }
  }
  
  private func clearMarker() {
    for marker in self.markers {
      marker.mapView = nil
    }
  }
  
  private func showDenyAlert() {
    AlertUtils.showWithCancel(
      controller: self,
      title: "location_deny_title".localized,
      message: "location_deny_description".localized,
      okButtonTitle: "설정",
      onTapOk: self.goToAppSetting
    )
  }
  
  private func goToAppSetting() {
    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
      return
    }
    
    if UIApplication.shared.canOpenURL(settingsUrl) {
      UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }
  }
  
  private func goToToss() {
    let tossScheme = Bundle.main.object(forInfoDictionaryKey: "Toss scheme") as? String ?? ""
    guard let url = URL(string: tossScheme) else { return }
    
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
  
  private func showSearchAddress() {
    let searchAddressVC = SearchAddressVC.instacne().then {
      $0.transitioningDelegate = self
      $0.delegate = self
    }
    
    self.present(searchAddressVC, animated: true, completion: nil)
  }
  
  @objc private func initilizeLocationManager() {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    
    if CLLocationManager.locationServicesEnabled() {
      switch CLLocationManager.authorizationStatus() {
      case .authorizedAlways, .authorizedWhenInUse:
        self.initilizeNaverMap()
        self.locationManager.startUpdatingLocation()
      case .notDetermined:
        self.locationManager.requestWhenInUseAuthorization()
      case .denied, .restricted:
        self.showDenyAlert()
      default:
        let alertContent = AlertContent(
          title: "location_unknown_status".localized,
          message: "\(CLLocationManager.authorizationStatus())"
        )
        self.showSystemAlert(alert: alertContent)
        break
      }
    } else {
      Log.debug("위치 기능 활성화 필요!")
    }
  }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    self.viewModel.input.tapStore.onNext(indexPath.row)
  }
  
  func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    let pageWidth = CGFloat(264)
    let offsetHelper: CGFloat = self.previousOffset > scrollView.contentOffset.x ? -50 : 50
    let proportionalOffset = (scrollView.contentOffset.x + offsetHelper) / pageWidth
    
    self.previousOffset = scrollView.contentOffset.x

    var selectedIndex = Int(proportionalOffset.rounded())
    if selectedIndex < 0 {
      selectedIndex = 0
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      self.viewModel.input.selectStore.onNext(selectedIndex)
    }
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      let pageWidth = CGFloat(264)
      let proportionalOffset = scrollView.contentOffset.x / pageWidth
      let selectedIndex = Int(round(proportionalOffset))
      
      self.viewModel.input.selectStore.onNext(selectedIndex)
    }
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.viewModel.input.deselectCurrentStore.onNext(())
  }
}

extension HomeVC: CLLocationManagerDelegate {
  
  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    switch status {
    case .denied:
      self.showDenyAlert()
    case .authorizedAlways, .authorizedWhenInUse:
      self.initilizeLocationManager()
    default:
      break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let currentLocation = locations.last {
      let camera = NMFCameraUpdate(scrollTo: NMGLatLng(
        lat: currentLocation.coordinate.latitude,
        lng: currentLocation.coordinate.longitude
      ))
      camera.animation = .easeIn
      
      self.homeView.mapView.moveCamera(camera)
      
      if !self.mapAnimatedFlag {
        self.viewModel.input.mapLocation.onNext(nil)
        self.viewModel.input.currentLocation.onNext(currentLocation)
        self.viewModel.input.locationForAddress
          .onNext((
            currentLocation.coordinate.latitude,
            currentLocation.coordinate.longitude
          ))
      }
    }
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if let error = error as? CLError {
      switch error.code {
      case .denied:
        self.showDenyAlert()
      case .locationUnknown:
        AlertUtils.show(
          controller: self,
          title: "location_unknown_title".localized,
          message: "location_unknown_description".localized
        )
      default:
        AlertUtils.show(
          controller: self,
          title: "location_unknown_error_title".localized,
          message: "location_unknown_error_description".localized
        )
        Crashlytics.crashlytics().log("location Manager Error(error code: \(error.code.rawValue)")
      }
    }
  }
}

extension HomeVC: SearchAddressDelegate {
  func selectAddress(location: (Double, Double), name: String) {
    let location = CLLocation(latitude: location.0, longitude: location.1)
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(
      lat: location.coordinate.latitude,
      lng: location.coordinate.longitude
    ))
    cameraUpdate.animation = .easeIn
    
    self.homeView.mapView.moveCamera(cameraUpdate)
    self.viewModel.input.mapLocation.onNext(location)
    self.viewModel.input.tapResearch.onNext(())
    self.viewModel.output.address.accept(name)
  }
}

extension HomeVC: StoreDetailDelegate {
  
  func popup(store: Store) {
    self.viewModel.input.backFromDetail.onNext(store)
  }
}

extension HomeVC: NMFMapViewCameraDelegate {
  
  func mapView(
    _ mapView: NMFMapView,
    cameraWillChangeByReason reason: Int,
    animated: Bool
  ) {
    if reason == NMFMapChangedByGesture {
      let mapLocation = CLLocation(
        latitude: mapView.cameraPosition.target.lat,
        longitude: mapView.cameraPosition.target.lng
      )
      let distance = mapView.contentBounds.boundsLatLngs[0].distance(to: mapView.contentBounds.boundsLatLngs[1])
      
      self.viewModel.input.distance.onNext(distance / 3)
      self.viewModel.input.mapLocation.onNext(mapLocation)
    }
  }
}

extension HomeVC: UIViewControllerTransitioningDelegate {
  
  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    transition.transitionMode = .present
    transition.maskView.frame = self.homeView.addressContainerView.frame
    
    return transition
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    transition.transitionMode = .dismiss
    transition.maskOriginalFrame = self.homeView.addressContainerView.frame
    
    return transition
  }
}
