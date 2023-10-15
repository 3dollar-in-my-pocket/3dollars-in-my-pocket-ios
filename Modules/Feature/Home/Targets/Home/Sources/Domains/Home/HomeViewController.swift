import UIKit
import Combine

import Common
import DesignSystem
import StoreInterface
import Model
import DependencyInjection

import NMapsMap
import Then
import PanModal

typealias HomeStoreCardSanpshot = NSDiffableDataSourceSnapshot<HomeSection, HomeSectionItem>

public final class HomeViewController: BaseViewController {
    private let homeView = HomeView()
    private let viewModel = HomeViewModel()
    private lazy var dataSource = HomeDataSource(collectionView: homeView.collectionView, viewModel: viewModel)
    private var markers: [NMFMarker] = []
    
    private var isFirstLoad = true
    fileprivate let transition = SearchTransition()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem = UITabBarItem(title: nil, image: DesignSystemAsset.Icons.homeSolid.image, tag: 0)
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
        
        homeView.collectionView.delegate = self
        homeView.mapView.addCameraDelegate(delegate: self)
        viewModel.input.viewDidLoad.send(())
    }
    
    public override func bindViewModelInput() {
        // TODO: 다른 화면 구현 후 바인딩 필요
//        let selectCategory = PassthroughSubject<Category?, Never>()
//        let searchByAddress = PassthroughSubject<CLLocation, Never>()
//        let onTapCurrentMarker = PassthroughSubject<Void, Never>()
        
        homeView.categoryFilterButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapCategoryFilter)
            .store(in: &cancellables)
        
        homeView.sortingButton.sortTypePublisher
            .subscribe(viewModel.input.onToggleSort)
            .store(in: &cancellables)
        
        homeView.onlyBossToggleButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.onTapOnlyBoss)
            .store(in: &cancellables)
        
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
    }
    
    public override func bindViewModelOutput() {
        viewModel.output.address
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, address in
                owner.homeView.addressButton.bind(address: address)
            }
            .store(in: &cancellables)
        
        viewModel.output.categoryFilter
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, category in
                owner.homeView.categoryFilterButton.setCategory(category)
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
        
        viewModel.output.storeCards
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, storeCards in
                var section: HomeSection
                
                if storeCards.isEmpty {
                    section = HomeSection(items: [HomeSectionItem.empty])
                } else {
                    section = HomeSection(items: storeCards.map { HomeSectionItem.storeCard($0) })
                }
                owner.updateDataSource(section: [section])
            }
            .store(in: &cancellables)
        
        viewModel.output.scrollToIndex
            .combineLatest(viewModel.output.storeCards)
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, storeCardWithSelectIndex in
                let (selectIndex, storeCards) = storeCardWithSelectIndex
                guard storeCards.count > selectIndex else {
                    owner.clearMarker()
                    return
                }
                
                let indexPath = IndexPath(row: selectIndex, section: 0)
                
                owner.selectMarker(selectedIndex: selectIndex, storeCards: storeCards)
                owner.homeView.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
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
                case .presentCategoryFilter(let category):
                    let categoryFilterViewController = CategoryFilterViewController.instance(selectedCategory: category)
                    categoryFilterViewController.delegate = self
                    owner.presentPanModal(categoryFilterViewController)
                    
                case .presentListView(let state):
                    let viewController = HomeListViewController.instance(state: state)
                    
                    owner.navigationController?.present(viewController, animated: true)
                    
                case .pushStoreDetail(let storeId):
                    owner.pushStoreDetail(storeId: storeId)
                    
                case .pushBossStoreDetail(let storeId):
                    ToastManager.shared.show(message: "🔥 사장님 가게 상세 화면 구현 필요")
                    
                case .presentVisit(let storeCard):
                    let storeId = Int(storeCard.storeId) ?? 0
                    owner.presentVisit(storeId: storeId, store: storeCard)
                    
                case .presentPolicy:
                    ToastManager.shared.show(message: "🔥 처리 방침 구현 필요")
                    
                case .presentMarkerAdvertisement:
                    ToastManager.shared.show(message: "🔥 마커 광고 화면 구현 필요")
                    
                case .presentSearchAddress(let viewModel):
                    owner.presentSearchAddress(viewModel)
                    
                case .showErrorAlert(let error):
                    if error is LocationError {
                        owner.showDenyAlert()
                    } else {
                        owner.showErrorAlert(error: error)
                    }
                }
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
    
    private func selectMarker(selectedIndex: Int?, storeCards: [StoreCard]) {
        clearMarker()
        
        for value in storeCards.enumerated() {
            let marker = NMFMarker()
            
            if selectedIndex == value.offset {
                marker.width = 32
                marker.height = 40
                marker.iconImage = NMFOverlayImage(image: HomeAsset.iconMarkerFocused.image)
            } else {
                marker.width = 24
                marker.height = 24
                marker.iconImage = NMFOverlayImage(image: HomeAsset.iconMarkerUnfocused.image)
            }
            guard let latitude = value.element.location?.latitude,
                  let longitude = value.element.location?.longitude else { break }
            let position = NMGLatLng(lat: latitude, lng: longitude)
            
            marker.position = position
            marker.mapView = homeView.mapView
            marker.touchHandler = { [weak self] _ in
                self?.viewModel.input.onTapMarker.send(value.offset)
                return true
            }
            markers.append(marker)
        }
    }
    
    private func clearMarker() {
        for marker in self.markers {
            marker.mapView = nil
        }
        self.markers.removeAll()
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
        guard let storeInterface = DIContainer.shared.container.resolve(StoreInterface.self) else  { return }
        let viewController = storeInterface.getStoreDetailViewController(storeId: storeId)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentVisit(storeId: Int, store: VisitableStore) {
        guard let storeInterface = DIContainer.shared.container.resolve(StoreInterface.self) else  { return }
        let viewController = storeInterface.getVisitViewController(storeId: storeId, visitableStore: store) {
            // TODO: 성공 시, 재조회 필요
        }
        
        tabBarController?.present(viewController, animated: true)
    }
    
    private func presentSearchAddress(_ viewModel: SearchAddressViewModel) {
        let viewController = SearchAddressViewController(viewModel: viewModel)
//        viewController.transitioningDelegate = self
        
        tabBarController?.present(viewController, animated: true, completion: nil)
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
        } else if reason == NMFMapChangedByDeveloper && isFirstLoad {
            isFirstLoad = false
            let distance = mapView
                .contentBounds
                .boundsLatLngs[0]
                .distance(to: mapView.contentBounds.boundsLatLngs[1])
            
            viewModel.input.onMapLoad.send(distance)
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

extension HomeViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.onTapStore.send(indexPath.row)
    }
}

extension HomeViewController: CategoryFilterDelegate {
    func onSelectCategory(category: PlatformStoreCategory?) {
        viewModel.input.selectCategory.send(category)
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
