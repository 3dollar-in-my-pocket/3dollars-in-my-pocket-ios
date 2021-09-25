import UIKit
import RxSwift
import NMapsMap
import FirebaseCrashlytics

class HomeVC: BaseVC {
  lazy var coordinator = HomeCoordinator(presenter: self)
  private let homeView = HomeView()
  private let viewModel = HomeViewModel(
    storeService: StoreService(),
    mapService: MapService(),
    userDefaults: UserDefaultsUtil()
  )
  
  var mapAnimatedFlag = false
  var previousOffset: CGFloat = 0
  var markers: [NMFMarker] = []
  fileprivate let transition = SearchTransition()
  
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
  
  override func loadView() {
    self.view = self.homeView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.initilizeShopCollectionView()
    self.fetchStoresFromCurrentLocation()
  }
  
  override func bindViewModelInput() {
    self.homeView.researchButton.rx.tap
      .bind(to: self.viewModel.input.tapResearch)
      .disposed(by: disposeBag)
    
    self.homeView.currentLocationButton.rx.tap
      .do(onNext: { [weak self] _ in
        self?.mapAnimatedFlag = true
        GA.shared.logEvent(event: .current_location_button_clicked, page: .home_page)
      })
      .bind(onNext: self.fetchStoresFromCurrentLocation)
      .disposed(by: self.disposeBag)
  }
  
  override func bindViewModelOutput() {
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
      .bind(onNext: self.coordinator.goToDetail(storeId:))
      .disposed(by: disposeBag)
    
    self.viewModel.showLoading
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
        .bind(onNext: self.coordinator.showSearchAddress)
      .disposed(by: disposeBag)
            
    self.homeView.tossButton.rx.tap
      .do(onNext: { _ in
        GA.shared.logEvent(event: .toss_button_clicked, page: .home_page)
      })
      .observeOn(MainScheduler.instance)
        .bind(onNext: self.coordinator.goToToss)
      .disposed(by: disposeBag)
  }
  
  func fetchStoresFromCurrentLocation() {
    LocationManager.shared.getCurrentLocation()
      .subscribe(
        onNext: { [weak self] location in
          guard let self = self else { return }
          let camera = NMFCameraUpdate(scrollTo: NMGLatLng(
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude
          ))
          camera.animation = .easeIn
          
          self.homeView.mapView.moveCamera(camera)
          
          if !self.mapAnimatedFlag {
            self.viewModel.input.mapLocation.onNext(nil)
            self.viewModel.input.currentLocation.onNext(location)
            self.viewModel.input.locationForAddress
              .onNext((
                location.coordinate.latitude,
                location.coordinate.longitude
              ))
          }
        },
        onError: self.handleLocationError(error:)
      )
      .disposed(by: self.disposeBag)
  }
  
  private func initilizeShopCollectionView() {
    self.homeView.storeCollectionView.delegate = self
  }
  
  private func initilizeNaverMap() {
    self.homeView.mapView.positionMode = .direction
    self.homeView.mapView.zoomLevel = 15
    self.homeView.mapView.addCameraDelegate(delegate: self)
  }
  
  private func selectMarker(selectedIndex: Int, stores: [Store]) {
    self.clearMarker()
    
    for index in stores.indices {
      let store = stores[index]
      let marker = NMFMarker()
      
      marker.position = NMGLatLng(lat: store.latitude, lng: store.longitude)
      if index == selectedIndex {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(
          lat: store.latitude,
          lng: store.longitude
        ))
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
      marker.touchHandler = { [weak self] _ in
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
  
  private func handleLocationError(error: Error) {
    if let locationError = error as? LocationError {
      if locationError == .denied {
        self.coordinator.showDenyAlert()
      } else {
        AlertUtils.show(controller: self, title: nil, message: locationError.errorDescription)
      }
    } else {
      self.showErrorAlert(error: error)
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
      let distance = mapView
        .contentBounds
        .boundsLatLngs[0]
        .distance(to: mapView.contentBounds.boundsLatLngs[1])
      
      self.viewModel.input.mapMaxDistance.onNext(distance / 3)
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
    self.transition.transitionMode = .present
    self.transition.maskView.frame = self.homeView.addressContainerView.frame
    
    return self.transition
  }
  
  func animationController(
    forDismissed dismissed: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    self.transition.transitionMode = .dismiss
    self.transition.maskOriginalFrame = self.homeView.addressContainerView.frame
    
    return self.transition
  }
}
