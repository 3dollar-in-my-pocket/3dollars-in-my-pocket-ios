import UIKit
import Combine

import Common
import DesignSystem
import Model

import NMapsMap
import Then
import PanModal
import Log

typealias HomeStoreCardSanpshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>

public final class HomeViewController: BaseViewController {
    public override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private lazy var homeView = HomeView(homeFilterSelectable: viewModel)
    private let viewModel = HomeViewModel()
    private lazy var dataSource = HomeDataSource(
        collectionView: homeView.collectionView,
        viewModel: viewModel,
        rootViewController: self
    )
    private var markers: [NMFMarker?] = []
    
    private var isFirstLoad = true
    fileprivate let transition = SearchTransition()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem = UITabBarItem(
            title: nil,
            image: DesignSystemAsset.Icons.homeSolid.image,
            tag: TabBarTag.home.rawValue
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func instance() -> UINavigationController {
        let viewController = HomeViewController()
        
        return UINavigationController(rootViewController: viewController).then {
            $0.isNavigationBarHidden = true
            $0.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    public override func loadView() {
        view = homeView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        homeView.mapView.addCameraDelegate(delegate: self)
        viewModel.input.viewDidLoad.send(())
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstLoad {
            isFirstLoad = false
            
            let distance = homeView.mapView
                .contentBounds
                .boundsLatLngs[0]
                .distance(to: homeView.mapView.contentBounds.boundsLatLngs[1])
            
            viewModel.input.onMapLoad.send(distance / 3)
        }
    }
    
    public override func bindViewModelInput() {
        homeView.addressButton.tap
            .mapVoid
            .subscribe(viewModel.input.onTapSearchAddress)
            .store(in: &cancellables)
        
        homeView.researchButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapResearch)
            .store(in: &cancellables)
        
        homeView.currentLocationButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapCurrentLocation)
            .store(in: &cancellables)
        
        homeView.listViewButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapListView)
            .store(in: &cancellables)
        
        homeView.researchButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapResearch)
            .store(in: &cancellables)
        
        if let layout = homeView.collectionView.collectionViewLayout as? HomeCardFlowLayout {
            layout.currentIndexPublisher
                .subscribe(viewModel.input.selectStore)
                .store(in: &cancellables)
        }
        
        homeView.mapView.locationOverlay.touchHandler = { [weak self] _ in
            self?.viewModel.input.onTapCurrentMarker.send(())
            return true
        }
        
        homeView.homeFilterCollectionView.onLoadFilter = { [weak self] in
            self?.viewModel.input.onLoadFilter.send(())
        }
    }
    
    public override func bindViewModelOutput() {
        viewModel.output.address
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, address in
                owner.homeView.addressButton.bind(address: address)
            }
            .store(in: &cancellables)
        
        viewModel.output.isHiddenResearchButton
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, isHidden in
                owner.homeView.setHiddenResearchButton(isHidden: isHidden)
            }
            .store(in: &cancellables)
        
        viewModel.output.cameraPosition
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, location in
                owner.homeView.moveCamera(location: location)
            }
            .store(in: &cancellables)
        
        viewModel.output.advertisementMarker
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, advertisement: AdvertisementResponse) in
                owner.homeView.setAdvertisementMarker(advertisement)
            }
            .store(in: &cancellables)
        
        viewModel.output.collectionItems
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, items: [HomeSectionItem]) in
                let section = HomeSection(items: items)
                owner.updateDataSource(section: [section])
            }
            .store(in: &cancellables)
        
        viewModel.output.scrollToIndex
            .combineLatest(viewModel.output.collectionItems)
            .main
            .sink { [weak self] index, items in
                guard let self,
                      items.count > index else {
                    self?.clearMarker()
                    return
                }
                
                let indexPath = IndexPath(row: index, section: 0)
                let stores = items.map { $0.store }
                
                selectMarker(selectedIndex: index, stores: stores)
                homeView.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, isShow in
                LoadingManager.shared.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .presentCategoryFilter(let viewModel):
                    let categoryFilterViewController = CategoryFilterViewController(viewModel: viewModel)
                    owner.presentPanModal(categoryFilterViewController)
                    
                case .presentListView(let viewModel):
                    owner.presentHomeList(viewModel)
                    
                case .pushStoreDetail(let storeId):
                    owner.pushStoreDetail(storeId: storeId)
                    
                case .pushBossStoreDetail(let storeId):
                    owner.pushBossStoreDetail(storeId: storeId)

                case .presentVisit(let store):
                    let storeId = Int(store.storeId) ?? 0
                    owner.presentVisit(storeId: storeId, store: store)
                    
                case .presentPolicy:
                    owner.presentPolicy()
                    
                case .presentMarkerAdvertisement:
                    owner.presentMarkerPopup()
                    
                case .presentSearchAddress(let viewModel):
                    owner.presentSearchAddress(viewModel)
                    
                case .showErrorAlert(let error):
                    if error is LocationError {
                        owner.showDenyAlert()
                    } else {
                        owner.showErrorAlert(error: error)
                    }
                    
                case .openURL(let urlString):
                    guard let url = URL(string: urlString) else { return }
                    UIApplication.shared.open(url)
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.isShowFilterTooltip
            .main
            .withUnretained(self)
            .sink { (owner: HomeViewController, isShow: Bool) in
                owner.homeView.showFilterTooltiop(isShow: isShow)
            }
            .store(in: &cancellables)
    }
    
    private func updateDataSource(section: [HomeSection]) {
        var snapshot = HomeStoreCardSanpshot()
        
        section.forEach {
            snapshot.appendSections([$0])
            snapshot.appendItems($0.items)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func selectMarker(selectedIndex: Int?, stores: [StoreWithExtraResponse?]) {
        clearMarker()
        
        for value in stores.enumerated() {
            let marker = NMFMarker()
            
            if let store = value.element {
                if selectedIndex == value.offset {
                    marker.width = 32
                    marker.height = 40
                    marker.iconImage = NMFOverlayImage(image: HomeAsset.iconMarkerFocused.image)
                } else {
                    marker.width = 24
                    marker.height = 24
                    marker.iconImage = NMFOverlayImage(image: HomeAsset.iconMarkerUnfocused.image)
                }
                guard let latitude = store.store.location?.latitude,
                      let longitude = store.store.location?.longitude else { break }
                let position = NMGLatLng(lat: latitude, lng: longitude)
                
                marker.position = position
                marker.mapView = homeView.mapView
                marker.touchHandler = { [weak self] _ in
                    self?.viewModel.input.onTapMarker.send(value.offset)
                    return true
                }
                markers.append(marker)
            } else {
                markers.append(nil)
            }
        }
    }
    
    private func clearMarker() {
        for marker in self.markers {
            marker?.mapView = nil
        }
        markers.removeAll()
    }
    
    private func showDenyAlert() {
        AlertUtils.showWithAction(
            viewController: self,
            title: HomeStrings.locationDenyTitle,
            message: HomeStrings.locationDenyDescription
        ) { [weak self] in
            self?.goToAppSetting()
        }
    }
    
    private func goToAppSetting() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
    
    private func pushStoreDetail(storeId: Int) {
        let viewController = Environment.storeInterface.getStoreDetailViewController(storeId: storeId)
        
        tabBarController?.navigationController?.pushViewController(viewController, animated: true)
    }

    private func pushBossStoreDetail(storeId: String) {
        let viewController = Environment.storeInterface.getBossStoreDetailViewController(storeId: storeId)

        tabBarController?.navigationController?.pushViewController(viewController, animated: true)
    }

    private func presentVisit(storeId: Int, store: VisitableStore) {
        let viewController = Environment.storeInterface.getVisitViewController(storeId: storeId, visitableStore: store) {
            // TODO: 성공 시, 재조회 필요
        }
        
        tabBarController?.present(viewController, animated: true)
    }
    
    private func presentSearchAddress(_ viewModel: SearchAddressViewModel) {
        let viewController = SearchAddressViewController(viewModel: viewModel)
        
        tabBarController?.present(viewController, animated: true, completion: nil)
    }
    
    private func presentMarkerPopup() {
        let viewController = MarkerPopupViewController()
        
        tabBarController?.present(viewController, animated: true)
    }
    
    private func presentPolicy() {
        let viewController = Environment.membershipInterface.createPolicyViewController()
        
        tabBarController?.present(viewController, animated: true)
    }
    
    private func presentHomeList(_ viewModel: HomeListViewModel) {
        let viewController = HomeListViewController(viewModel: viewModel)
        viewController.delegate = self
        viewController.hidesBottomBarWhenPushed = true
        viewController.modalPresentationStyle = .currentContext
        
        navigationController?.present(viewController, animated: true)
    }
}

extension HomeViewController: NMFMapViewCameraDelegate {
    public func mapView(
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
            
            viewModel.input.changeMaxDistance.send(distance / 3)
            viewModel.input.changeMapLocation.send(mapLocation)
        }
    }
    
    public func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        if reason == NMFMapChangedByGesture {
            let mapLocation = CLLocation(
                latitude: mapView.cameraPosition.target.lat,
                longitude: mapView.cameraPosition.target.lng
            )
            let distance = mapView
                .contentBounds
                .boundsLatLngs[0]
                .distance(to: mapView.contentBounds.boundsLatLngs[1])
            
            viewModel.input.changeMaxDistance.send(distance / 3)
            viewModel.input.changeMapLocation.send(mapLocation)
        }
    }
}

extension HomeViewController: HomeListDelegate {
    func didTapUserStore(storeId: Int) {
        pushStoreDetail(storeId: storeId)
    }
    
    func didTapBossStore(storeId: String) {
        pushBossStoreDetail(storeId: storeId)
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.maskView.frame = homeView.addressButton.frame
        
        return transition
    }
    
    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.maskOriginalFrame = homeView.addressButton.frame
        
        return transition
    }
}
