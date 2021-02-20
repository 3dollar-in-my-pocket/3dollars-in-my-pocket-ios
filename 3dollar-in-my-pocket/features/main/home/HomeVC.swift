import UIKit
import RxSwift
import NMapsMap
import FirebaseCrashlytics


class HomeVC: BaseVC {
  
  private lazy var homeView = HomeView(frame: self.view.frame)
  private let viewModel = HomeViewModel(storeService: StoreService())
  private let locationManager = CLLocationManager()
  
  var previousIndex = 0
  var mapAnimatedFlag = false
  var previousOffset: CGFloat = 0
  var markers: [NMFMarker] = []
  
  static func instance() -> UINavigationController {
    let homeVC = HomeVC(nibName: nil, bundle: nil).then {
      $0.tabBarItem = UITabBarItem(
        title: nil,
        image: UIImage(named: "ic_home"),
        tag: TabBarTag.home.rawValue
      )
    }
    
    return UINavigationController(rootViewController: homeVC).then {
      $0.isNavigationBarHidden = true
    }
  }
  
  deinit {
    self.locationManager.stopUpdatingLocation()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = homeView
    
    self.initilizeShopCollectionView()
    self.initilizeLocationManager()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.addForegroundObserver()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    self.removeForegroundObserver()
  }
  
  override func bindViewModel() {
    // Bind output
    self.viewModel.output.stores
      .bind(to: homeView.storeCollectionView.rx.items(
        cellIdentifier: ShopCell.registerId,
        cellType: ShopCell.self
      )) { row, storeCard, cell in
        cell.bind(storeCard: storeCard)
      }.disposed(by: disposeBag)
    
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
      .bind(onNext: self.homeView.showLoading(isShow:))
      .disposed(by: disposeBag)
  }
  
  override func bindEvent() {
    self.homeView.currentLocationButton.rx.tap
      .observeOn(MainScheduler.instance)
      .bind { [weak self] in
        self?.mapAnimatedFlag = true
        self?.locationManager.startUpdatingLocation()
      }
      .disposed(by: disposeBag)
  }
  
  private func addForegroundObserver() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(initilizeLocationManager),
      name: UIApplication.willEnterForegroundNotification, object: nil
    )
  }
  
  private func removeForegroundObserver() {
    NotificationCenter.default.removeObserver(self)
  }
  
  private func initilizeShopCollectionView() {
    self.homeView.storeCollectionView.delegate = self
    self.homeView.storeCollectionView.register(
      ShopCell.self,
      forCellWithReuseIdentifier: ShopCell.registerId
    )
  }
  
  private func initilizeNaverMap() {
    self.homeView.mapView.positionMode = .direction
    self.homeView.mapView.zoomLevel = 15
  }
  
  private func goToDetail(storeId: Int) {
    self.navigationController?.pushViewController(
      StoreDetailVC.instance(storeId: storeId),
      animated: true
    )
  }
  
  private func selectMarker(selectedIndex: Int, storeCards: [StoreCard]) {
    self.clearMarker()
    
    for index in storeCards.indices {
      let storeCard = storeCards[index]
      let marker = NMFMarker()
      
      marker.position = NMGLatLng(lat: storeCard.latitude, lng: storeCard.longitude)
      if index == selectedIndex {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: storeCard.latitude, lng: storeCard.longitude))
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
      self.markers.append(marker)
    }
  }
  
  private func clearMarker() {
    for marker in self.markers {
      marker.mapView = nil
    }
  }
  
  private func showDenyAlert() {
    AlertUtils.showWithAction(
      title: "location_deny".localized,
      message: "location_deny_description".localized
    ) { action in
      UIControl().sendAction(
        #selector(URLSessionTask.suspend),
        to: UIApplication.shared, for: nil
      )
    }
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
    
    var selectedIndex = Int(proportionalOffset.rounded()) >= 5 ? 4 : Int(proportionalOffset.rounded())
    if selectedIndex < 0 {
      selectedIndex = 0
    }
    
    let indexPath = IndexPath(row: selectedIndex, section: 0)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      self.homeView.scrollToIndex(index: indexPath)
    }
  }
  
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    let pageWidth = CGFloat(264)
    let proportionalOffset = scrollView.contentOffset.x / pageWidth
    
    var selectedIndex = Int(proportionalOffset.rounded())
    if selectedIndex < 0 {
      selectedIndex = 0
    }
    self.viewModel.input.selectStore.onNext(selectedIndex)
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
      AlertUtils.showWithAction(
        title: "location_deny_title".localized,
        message: "location_deny_description".localized
      ) { action in
        UIControl().sendAction(
          #selector(URLSessionTask.suspend),
          to: UIApplication.shared, for: nil
        )
      }
    case .authorizedAlways, .authorizedWhenInUse:
      self.initilizeLocationManager()
    default:
      break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations.last
    let camera = NMFCameraUpdate(scrollTo: NMGLatLng(
      lat: location!.coordinate.latitude,
      lng: location!.coordinate.longitude
    ))
    
    if self.mapAnimatedFlag {
      camera.animation = .easeIn
    }
    self.homeView.mapView.moveCamera(camera)
    self.viewModel.input.location.onNext((
      location!.coordinate.latitude,
      location!.coordinate.longitude
    ))
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if let error = error as? CLError {
      switch error.code {
      case .denied:
        AlertUtils.show(
          controller: self,
          title: "location_deny_title".localized,
          message: "location_deny_description".localized
        )
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
