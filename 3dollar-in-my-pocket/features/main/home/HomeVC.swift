import UIKit
import NMapsMap
import FirebaseCrashlytics


class HomeVC: BaseVC {
  
  private lazy var homeView = HomeView(frame: self.view.frame)
  
  var viewModel = HomeViewModel()
  var locationManager = CLLocationManager()
  var isFirst = true
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
    locationManager.stopUpdatingLocation()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view = homeView
    
    self.initilizeShopCollectionView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.initilizeLocationManager()
    self.addForegroundObserver()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    self.removeForegroundObserver()
  }
  
  override func bindViewModel() {
    self.viewModel.nearestStore
      .bind(to: homeView.shopCollectionView.rx.items(cellIdentifier: ShopCell.registerId, cellType: ShopCell.self)) { [weak self] row, storeCard, cell in
        if let vc = self {
          if row == 0 && vc.isFirst == true {
            cell.setSelected(isSelected: true)
            vc.isFirst = false
          } else {
            cell.setSelected(isSelected: false)
          }
          cell.bind(storeCard: storeCard)
        }
      }.disposed(by: disposeBag)
    
    self.viewModel.location.subscribe(onNext: { [weak self] (latitude, longitude) in
      self?.previousIndex = 0
      self?.getNearestStore(latitude: latitude, longitude: longitude)
    }).disposed(by: disposeBag)
    
    self.homeView.currentLocationButton.rx.tap.bind { [weak self] in
      self?.mapAnimatedFlag = true
      self?.locationManager.startUpdatingLocation()
    }.disposed(by: disposeBag)
  }
  
  func onSuccessWrite() {
    isFirst = true
    mapAnimatedFlag = false
    locationManager.startUpdatingLocation()
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
    self.homeView.shopCollectionView.delegate = self
    self.homeView.shopCollectionView.register(
      ShopCell.self,
      forCellWithReuseIdentifier: ShopCell.registerId
    )
  }
  
  @objc private func initilizeLocationManager() {
    self.isFirst = true
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
        Log.error("알 수 없는 위치 권한: \(CLLocationManager.authorizationStatus())")
        break
      }
    } else {
      Log.debug("위치 기능 활성화 필요!")
    }
  }
  
  private func initilizeNaverMap() {
    self.homeView.mapView.positionMode = .direction
  }
  
  private func goToDetail(storeId: Int) {
    self.navigationController?.pushViewController(StoreDetailVC.instance(storeId: storeId), animated: true)
  }
  
  private func getNearestStore(latitude: Double, longitude: Double) {
    self.homeView.showLoading(isShow: true)
    StoreService().getStoreOrderByNearest(latitude: latitude, longitude: longitude).subscribe(
      onNext: { [weak self] storeCards in
        guard let self = self else { return }
        self.isFirst = true
        self.viewModel.nearestStore.onNext(storeCards)
        self.homeView.shopCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: true)
        self.selectMarker(selectedIndex: 0, storeCards: storeCards)
        self.homeView.showLoading(isShow: false)
      },
      onError: { [weak self] error in
        guard let self = self else { return }
        if let httpError = error as? HTTPError {
          self.showHTTPErrorAlert(error: httpError)
        } else if let error = error as? CommonError {
          let alertContent = AlertContent(title: nil, message: error.description)
          
          self.showSystemAlert(alert: alertContent)
        }
      })
      .disposed(by: disposeBag)
  }
  
  private func markerWithSize(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
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
        marker.iconImage = NMFOverlayImage(name: "ic_marker_store_on")
      } else {
        marker.iconImage = NMFOverlayImage(name: "ic_marker_store_off")
      }
      marker.width = 16
      marker.height = 16
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
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if previousIndex == indexPath.row { // 셀이 선택된 상태에서 한번 더 누르는 경우 상세화면으로 이동
      GA.shared.logEvent(event: .store_card_button_clicked, page: .home_page)
      goToDetail(storeId: try! self.viewModel.nearestStore.value()[indexPath.row].id)
    } else {
      collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
      if let cell = self.homeView.shopCollectionView.cellForItem(at: IndexPath(row: previousIndex, section: 0)) as? ShopCell {
        // 기존에 눌려있던 셀 deselect
        cell.setSelected(isSelected: false)
      }
      
      if let cell = self.homeView.shopCollectionView.cellForItem(at: indexPath) as? ShopCell {
        // 새로 누른 셀 select
        cell.setSelected(isSelected: true)
        self.selectMarker(selectedIndex: indexPath.row, storeCards: try! self.viewModel.nearestStore.value())
      }
      previousIndex  = indexPath.row
    }
  }
  
  func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    let pageWidth = CGFloat(264)
    let offsetHelper: CGFloat = self.previousOffset > scrollView.contentOffset.x ? -50 : 50
    let proportionalOffset = (scrollView.contentOffset.x + offsetHelper) / pageWidth
    
    self.previousOffset = scrollView.contentOffset.x
    
    previousIndex = Int(proportionalOffset.rounded()) >= 5 ? 4 : Int(proportionalOffset.rounded())
    if previousIndex < 0 {
      previousIndex = 0
    }
    
    let indexPath = IndexPath(row: previousIndex, section: 0)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      self.homeView.shopCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
  }
  
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    let pageWidth = CGFloat(264)
    let proportionalOffset = scrollView.contentOffset.x / pageWidth
    
    previousIndex = Int(proportionalOffset.rounded())
    if previousIndex < 0 {
      previousIndex = 0
    }
    
    let indexPath = IndexPath(row: previousIndex, section: 0)
    
    if let cell = self.homeView.shopCollectionView.cellForItem(at: indexPath) as? ShopCell {
      cell.setSelected(isSelected: true)
      self.selectMarker(selectedIndex: indexPath.row, storeCards: try! self.viewModel.nearestStore.value())
    }
  }
  
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      let pageWidth = CGFloat(264)
      let proportionalOffset = scrollView.contentOffset.x / pageWidth
      previousIndex = Int(round(proportionalOffset))
      let indexPath = IndexPath(row: previousIndex, section: 0)
      
      self.homeView.shopCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
      if let cell = self.homeView.shopCollectionView.cellForItem(at: indexPath) as? ShopCell {
        cell.setSelected(isSelected: true)
        self.selectMarker(selectedIndex: indexPath.row, storeCards: try! self.viewModel.nearestStore.value())
      }
    }
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    let indexPath = IndexPath(row: previousIndex, section: 0)
    
    if let cell = self.homeView.shopCollectionView.cellForItem(at: indexPath) as? ShopCell {
      cell.setSelected(isSelected: false)
    }
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
        title: "위치 권한 거절",
        message: "설정 > 가슴속 3천원 > 위치에서 위치 권한을 확인해주세요."
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
  
  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    let location = locations.last
    let camera = NMFCameraUpdate(scrollTo: NMGLatLng(
      lat: location!.coordinate.latitude,
      lng: location!.coordinate.longitude
    ))
    
    if self.mapAnimatedFlag {
      camera.animation = .easeIn
    }
    self.homeView.mapView.moveCamera(camera)
    if isFirst {
      self.viewModel.location.onNext((location!.coordinate.latitude, location!.coordinate.longitude))
    }
    locationManager.stopUpdatingLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    if let error = error as? CLError {
      switch error.code {
      case .denied:
        AlertUtils.show(
          controller: self,
          title: "위치 권한 거절",
          message: "설정 > 가슴속 3천원 > 위치에서 위치 권한을 확인해주세요."
        )
      case .locationUnknown:
        AlertUtils.show(
          controller: self,
          title: "알 수 없는 위치",
          message: "현재 위치가 확인되지 않습니다.\n잠시 후 다시 시도해주세요."
        )
      default:
        AlertUtils.show(
          controller: self,
          title: "위치 오류 발생",
          message: "위치 오류가 발생되었습니다.\n에러가 개발자에게 보고됩니다."
        )
        Crashlytics.crashlytics().log("location Manager Error(error code: \(error.code.rawValue)")
      }
    }
  }
}
