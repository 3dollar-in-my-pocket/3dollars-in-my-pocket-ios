import UIKit

import RxSwift
import RxDataSources
import ReactorKit
import NMapsMap

final class FoodTruckListViewController: BaseViewController, View, FoodTruckListCoordinator {
    private let foodTruckListView = FoodTruckListView()
    private let foodTruckListReactor = FoodTruckListReactor(
        storeService: StoreService(),
        advertisementService: AdvertisementService(),
        locationManager: LocationManager.shared,
        metaContext: MetaContext.shared,
        globalState: GlobalState.shared
    )
    private weak var coordinator: FoodTruckListCoordinator?
    private var foodTruckStoreCollectionViewDataSource:
    RxCollectionViewSectionedReloadDataSource<FoodTruckListSectionModel>!
    
    static func instance() -> UINavigationController {
        let viewController = FoodTruckListViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: R.string.localization.tab_food_truck(),
                image: UIImage(named: "ic_food_truck"),
                tag: TabBarTag.foodTruck.rawValue
            )
        }
        
        return UINavigationController(rootViewController: viewController).then {
            $0.setNavigationBarHidden(true, animated: false)
            $0.interactivePopGestureRecognizer?.delegate = nil
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.setupDateSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.foodTruckListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.foodTruckListReactor
        self.foodTruckListReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.foodTruckListReactor.pushBossStoreDetailPublisher
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.pushBossStoreDetail(storeId: storeId)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.foodTruckListReactor.presentCategoryFilterPublisher
            .asDriver(onErrorJustReturn: FoodTruckCategory.totalCategory)
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.presentCategoryFilter()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.foodTruckListReactor.openURLPublisher
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] url in
                self?.coordinator?.openURL(url: url)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.foodTruckListReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: FoodTruckListReactor) {
        // Bind Action
        self.foodTruckListView.categoryButton.rx.tap
            .map { Reactor.Action.tapCategory }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.category }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: FoodTruckCategory.totalCategory)
            .drive(self.foodTruckListView.rx.category)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { state -> [FoodTruckListSectionModel] in
                let mapSection = FoodTruckListSectionModel(stores: state.stores)
                let storeSection = FoodTruckListSectionModel(
                    stores: state.stores,
                    advertisement: state.advertisement
                )
                
                return [mapSection] + [storeSection]
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.foodTruckListView.collectionView.rx.items(
                dataSource: self.foodTruckStoreCollectionViewDataSource
            ))
            .disposed(by: self.disposeBag)
    }
    
    private func setupDateSource() {
        self.foodTruckStoreCollectionViewDataSource
        = RxCollectionViewSectionedReloadDataSource<FoodTruckListSectionModel>(
            configureCell: { _, collectionView, indexPath, item in
                switch item {
                case .map(let stores):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StreetFoodListMapCell.registerId,
                        for: indexPath
                    ) as? StreetFoodListMapCell else { return BaseCollectionViewCell() }
                    
                    cell.mapView.addCameraDelegate(delegate: self)
                    cell.currentLocationButton.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapCurrentLocationButton }
                        .bind(to: self.foodTruckListReactor.action)
                        .disposed(by: cell.disposeBag)
                    cell.bind(stores: stores)
                    
                    self.foodTruckListReactor.state
                        .map { $0.cameraPosition }
                        .distinctUntilChanged()
                        .asDriver(onErrorJustReturn: nil)
                        .drive(cell.rx.cameraPosition)
                        .disposed(by: cell.disposeBag)
                    
                    return cell
                    
                case .empty:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StreetFoodListEmptyCell.registerId,
                        for: indexPath
                    ) as? StreetFoodListEmptyCell else { return BaseCollectionViewCell() }
                    
                    return cell
                    
                case .store(let store):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: FoodTruckListStoreCell.registerId,
                        for: indexPath
                    ) as? FoodTruckListStoreCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(store: store)
                    cell.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapStore(index: indexPath.row)}
                        .bind(to: self.foodTruckListReactor.action)
                        .disposed(by: cell.disposeBag)
                    
                    return cell
                    
                case .advertisement(let advertisement):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StreetFoodListAdvertisementCell.registerId,
                        for: indexPath
                    ) as? StreetFoodListAdvertisementCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(advertisement: advertisement)
                    cell.rx.tap
                        .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                        .map { Reactor.Action.tapAdvertisement }
                        .bind(to: self.foodTruckListReactor.action)
                        .disposed(by: cell.disposeBag)
                    
                    return cell
                }
        })
        
        self.foodTruckStoreCollectionViewDataSource.configureSupplementaryView
        = { _, collectionView, kind, indexPath -> UICollectionReusableView in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: FoodTruckListHeaderView.registerId,
                    for: indexPath
                ) as? FoodTruckListHeaderView else { return UICollectionReusableView() }
                
                headerView.orderFilterButton.rx.orderType
                    .distinctUntilChanged()
                    .map {
                        $0 == .distance ? BossStoreOrderType.distance : BossStoreOrderType.feedback
                    }
                    .map { Reactor.Action.tapOrderButton($0) }
                    .bind(to: self.foodTruckListReactor.action)
                    .disposed(by: headerView.disposeBag)
                
                headerView.adBannerView.rootViewController = self
                
                self.foodTruckListReactor.state
                    .map { $0.category }
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: FoodTruckCategory.totalCategory)
                    .drive(headerView.rx.category)
                    .disposed(by: headerView.disposeBag)
                
                return headerView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
}

extension FoodTruckListViewController: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        if reason == NMFMapChangedByGesture {
            let mapLocation = CLLocation(
                latitude: mapView.cameraPosition.target.lat,
                longitude: mapView.cameraPosition.target.lng
            )

            if animated {
                self.foodTruckListReactor.action.onNext(.changeMapLocation(mapLocation))
            }
        }
    }
}
