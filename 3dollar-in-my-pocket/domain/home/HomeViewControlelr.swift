import UIKit

import RxSwift
import NMapsMap
import ReactorKit

final class HomeViewController: BaseVC, View, HomeCoordinator {
    weak var coordinator: HomeCoordinator?
    private let homeView = HomeView()
    private let homeReactor = HomeReactor(
        storeService: StoreService(),
        locationManager: LocationManager.shared,
        mapService: MapService(),
        userDefaults: UserDefaultsUtil()
    )
  
    var mapAnimatedFlag = false
    var previousOffset: CGFloat = 0
    var markers: [NMFMarker] = []
    fileprivate let transition = SearchTransition()
  
    static func instance() -> UINavigationController {
        let viewController = HomeViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: R.image.ic_home(),
                tag: TabBarTag.home.rawValue
            )
        }
        
        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
            $0.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    override func loadView() {
        self.view = self.homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.homeReactor
        self.initilizeShopCollectionView()
//        self.fetchStoresFromCurrentLocation()
        self.initilizeNaverMap()
        self.homeReactor.action.onNext(.tapCurrentLocationButton)
    }
    
    override func bindEvent() {
        self.homeView.addressButton.rx.tap
            .asDriver()
            .do(onNext: { _ in
                GA.shared.logEvent(event: .search_button_clicked, page: .home_page)
            })
            .drive(onNext: { [weak self] in
                self?.coordinator?.showSearchAddress()
            })
            .disposed(by: self.eventDisposeBag)
                
        self.homeView.tossButton.rx.tap
            .asDriver()
            .do(onNext: { _ in
                GA.shared.logEvent(event: .toss_button_clicked, page: .home_page)
            })
            .drive(onNext: { [weak self] in
                self?.coordinator?.goToToss()
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: HomeReactor) {
        // Bind Action
        self.homeView.researchButton.rx.tap
            .map { Reactor.Action.tapResearchButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.homeView.currentLocationButton.rx.tap
            .map { Reactor.Action.tapCurrentLocationButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.homeView.storeCollectionView.rx.itemSelected
            .map { Reactor.Action.tapStore(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        
        reactor.state
            .map { $0.storeCellTypes }
            .asDriver(onErrorJustReturn: [])
            .drive(
                self.homeView.storeCollectionView.rx.items
            ) { collectionView, row, storeCellType -> UICollectionViewCell in
                let indexPath = IndexPath(row: row, section: 0)
                
                switch storeCellType {
                case .store(let store):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: HomeStoreCell.registerId,
                        for: indexPath
                    ) as? HomeStoreCell else {
                        return BaseCollectionViewCell()
                    }
                    
                    cell.bind(store: store)
                    cell.visitButton.rx.tap
                        .map { Reactor.Action.tapVisitButton(index: row) }
                        .bind(to: self.homeReactor.action)
                        .disposed(by: cell.disposeBag)
                    return cell
                    
                case .advertisement(let advertisement):
                    // TODO: 새로운 셀 구현 후 바인딩 작업ㄱㄱ
                    return BaseCollectionViewCell()
                    
                case .empty:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: HomeEmptyStoreCell.registerId,
                        for: indexPath
                    ) as? HomeEmptyStoreCell else {
                        return BaseCollectionViewCell()
                    }
                    
                    return cell
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.address }
            .asDriver(onErrorJustReturn: "")
            .distinctUntilChanged()
            .drive(self.homeView.addressButton.rx.title(for: .normal))
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.isHiddenResearchButton }
            .asDriver(onErrorJustReturn: false)
            .drive(self.homeView.rx.isResearchButtonHidden)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.cameraPosition }
            .asDriver(onErrorJustReturn: CLLocation(latitude: 0, longitude: 0))
            .drive(self.homeView.rx.cameraPosition)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { ($0.selectedIndex, $0.storeCellTypes) }
            .asDriver(onErrorJustReturn: (nil, []))
            .drive(onNext: { [weak self] selectedIndex, storeCellTypes in
                self?.selectMarker(selectedIndex: selectedIndex, storeCellTypes: storeCellTypes)
            })
            .disposed(by: self.disposeBag)
    }
  
//  override func bindViewModelInput() {
//    self.homeView.researchButton.rx.tap
//      .bind(to: self.viewModel.input.tapResearch)
//      .disposed(by: disposeBag)
//
//    self.homeView.currentLocationButton.rx.tap
//      .do(onNext: { [weak self] _ in
//        self?.mapAnimatedFlag = true
//        GA.shared.logEvent(event: .current_location_button_clicked, page: .home_page)
//      })
//      .bind(onNext: self.fetchStoresFromCurrentLocation)
//      .disposed(by: self.disposeBag)
//  }
  
//  override func bindViewModelOutput() {
//    self.viewModel.output.address
//      .bind(to: self.homeView.addressButton.rx.title(for: .normal))
//      .disposed(by: disposeBag)
//
//    self.viewModel.output.stores
//      .bind(to: homeView.storeCollectionView.rx.items(
//        cellIdentifier: StoreCell.registerId,
//        cellType: StoreCell.self
//      )) { row, store, cell in
//        cell.bind(store: store)
//        cell.visitButton.rx.tap
//          .map { row }
//          .bind(to: self.viewModel.input.tapStoreVisit)
//          .disposed(by: cell.disposeBag)
//      }.disposed(by: disposeBag)
//
//    self.viewModel.output.isHiddenResearchButton
//      .observeOn(MainScheduler.instance)
//      .bind(onNext: self.homeView.isHiddenResearchButton(isHidden:))
//      .disposed(by: disposeBag)
//
//    self.viewModel.output.isHiddenEmptyCell
//      .bind(to: self.homeView.emptyCell.rx.isHidden)
//      .disposed(by: disposeBag)
//
//    self.viewModel.output.scrollToIndex
//      .observeOn(MainScheduler.instance)
//      .bind(onNext: self.homeView.scrollToIndex(index:))
//      .disposed(by: disposeBag)
//
//    self.viewModel.output.setSelectStore
//      .observeOn(MainScheduler.instance)
//      .bind(onNext: self.homeView.setSelectStore)
//      .disposed(by: disposeBag)
//
//    self.viewModel.output.selectMarker
//      .observeOn(MainScheduler.instance)
//      .bind(onNext: self.selectMarker)
//      .disposed(by: disposeBag)
//
//    self.viewModel.output.goToDetail
//      .observeOn(MainScheduler.instance)
//      .bind(onNext: { [weak self] storeId in
//        self?.coordinator?.goToDetail(storeId: storeId)
//      })
//      .disposed(by: disposeBag)
//
//    self.viewModel.output.presentVisit
//      .asDriver(onErrorJustReturn: Store())
//      .drive { [weak self] store in
//        self?.coordinator?.presentVisit(store: store)
//      }
//      .disposed(by: self.disposeBag)
//
//    self.viewModel.showLoading
//      .observeOn(MainScheduler.instance)
//      .bind(onNext: self.showRootLoading(isShow:))
//      .disposed(by: disposeBag)
//
//    self.viewModel.showSystemAlert
//      .observeOn(MainScheduler.instance)
//      .bind(onNext: self.showSystemAlert(alert:))
//      .disposed(by: disposeBag)
//  }
  
//  func fetchStoresFromCurrentLocation() {
//    LocationManager.shared.getCurrentLocation()
//      .subscribe(
//        onNext: { [weak self] location in
//          guard let self = self else { return }
//          let camera = NMFCameraUpdate(scrollTo: NMGLatLng(
//            lat: location.coordinate.latitude,
//            lng: location.coordinate.longitude
//          ))
//          camera.animation = .easeIn
//
//          self.homeView.mapView.moveCamera(camera)
//
//          if !self.mapAnimatedFlag {
//            self.viewModel.input.mapLocation.onNext(nil)
//            self.viewModel.input.currentLocation.onNext(location)
//            self.viewModel.input.locationForAddress
//              .onNext((
//                location.coordinate.latitude,
//                location.coordinate.longitude
//              ))
//          }
//        },
//        onError: self.handleLocationError(error:)
//      )
//      .disposed(by: self.disposeBag)
//  }
    
    private func initilizeShopCollectionView() {
        self.homeView.storeCollectionView.delegate = self
    }
    
    private func initilizeNaverMap() {
        self.homeView.mapView.addCameraDelegate(delegate: self)
    }
    
    private func selectMarker(selectedIndex: Int?, storeCellTypes: [StoreCellType]) {
        self.clearMarker()
        
        for index in storeCellTypes.indices {
            if case .store(let store) = storeCellTypes[index] {
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
                    marker.width = 24
                    marker.height = 24
                }
                marker.mapView = self.homeView.mapView
                marker.touchHandler = { [weak self] _ in
                    
                    self?.homeReactor.action.onNext(.tapStore(index: index))
                    return true
                }
                self.markers.append(marker)
            }
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
        self.coordinator?.showDenyAlert()
      } else {
        AlertUtils.show(controller: self, title: nil, message: locationError.errorDescription)
      }
    } else {
      self.showErrorAlert(error: error)
    }
  }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//  func collectionView(
//    _ collectionView: UICollectionView,
//    didSelectItemAt indexPath: IndexPath
//  ) {
//    self.viewModel.input.tapStore.onNext(indexPath.row)
//  }
  
  func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    let pageWidth = CGFloat(272)
    let offsetHelper: CGFloat = self.previousOffset > scrollView.contentOffset.x ? -50 : 50
    let proportionalOffset = (scrollView.contentOffset.x + offsetHelper) / pageWidth

    self.previousOffset = scrollView.contentOffset.x

    var selectedIndex = Int(proportionalOffset.rounded())
    if selectedIndex < 0 {
      selectedIndex = 0
    }

//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//      self.viewModel.input.selectStore.onNext(selectedIndex)
//    }
  }
}

extension HomeViewController: SearchAddressDelegate {
  func selectAddress(location: (Double, Double), name: String) {
//    let location = CLLocation(latitude: location.0, longitude: location.1)
//    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(
//      lat: location.coordinate.latitude,
//      lng: location.coordinate.longitude
//    ))
//    cameraUpdate.animation = .easeIn
//
//    self.homeView.mapView.moveCamera(cameraUpdate)
//    self.viewModel.input.mapLocation.onNext(location)
//    self.viewModel.input.tapResearch.onNext(())
//    self.viewModel.output.address.accept(name)
  }
}

extension HomeViewController: StoreDetailDelegate {
  func popup(store: Store) {
//    self.viewModel.input.backFromDetail.onNext(store)
  }
}

extension HomeViewController: NMFMapViewCameraDelegate {
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
      
//      self.viewModel.input.mapMaxDistance.onNext(distance / 3)
//      self.viewModel.input.mapLocation.onNext(mapLocation)
    }
  }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
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

extension HomeViewController: VisitViewControllerDelegate {
  func onSuccessVisit(store: Store) {
//    self.viewModel.input.updateStore.onNext(store)
  }
}
