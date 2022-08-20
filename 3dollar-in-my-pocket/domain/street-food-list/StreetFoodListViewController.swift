import UIKit

import Base
import RxSwift
import RxDataSources
import ReactorKit
import NMapsMap

final class StreetFoodListViewController: BaseViewController, StreetFoodListCoordinator, View {
    private let streetFoodListView = StreetFoodListView()
    private let streetFoodListReactor = StreetFoodListReactor(
        storeService: StoreService(),
        advertisementService: AdvertisementService(),
        locationManager: LocationManager.shared,
        metaContext: MetaContext.shared
    )
    private weak var coordinator: StreetFoodListCoordinator?
    private var streetFoodStoreCollectionViewDataSource:
    RxCollectionViewSectionedReloadDataSource<StreetFoodListSectionModel>!
    
    static func instance() -> UINavigationController {
        let viewController = StreetFoodListViewController(nibName: nil, bundle: nil).then {
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: UIImage(named: "ic_street_food"),
                tag: TabBarTag.streetFood.rawValue
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
        self.view = self.streetFoodListView
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.streetFoodListReactor
        self.streetFoodListReactor.action.onNext(.viewDidLoad)
    }
  
    override func bindEvent() {
        self.streetFoodListView.writeButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.presentWriteAddress()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.streetFoodListReactor.pushStoreDetailPublisher
            .asDriver(onErrorJustReturn: -1)
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.pushStoreDetail(storeId: storeId)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.streetFoodListReactor.presentCategoryFilterPublisher
            .asDriver(onErrorJustReturn: StreetFoodCategory.totalCategory)
            .drive(onNext: { [weak self] category in
                self?.coordinator?.presentCategoryFilter()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.streetFoodListReactor.openURLPublisher
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] url in
                self?.coordinator?.openURL(url: url)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.streetFoodListReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: StreetFoodListReactor) {
        // Bind Action
        self.streetFoodListView.categoryButton.rx.tap
            .map { Reactor.Action.tapCategory }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.category }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: StreetFoodCategory.totalCategory)
            .drive(self.streetFoodListView.rx.category)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { state -> [StreetFoodListSectionModel] in
                let mapSection = StreetFoodListSectionModel(stores: state.stores)
                let storeSection = StreetFoodListSectionModel(
                    stores: state.stores,
                    advertisement: state.advertisement,
                    isOnlyCertificated: state.isOnlyCertificated
                )
                
                return [mapSection] + [storeSection]
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.streetFoodListView.collectionView.rx.items(
                dataSource: self.streetFoodStoreCollectionViewDataSource
            ))
            .disposed(by: self.disposeBag)
    }
    
    private func setupDateSource() {
        self.streetFoodStoreCollectionViewDataSource
        = RxCollectionViewSectionedReloadDataSource<StreetFoodListSectionModel>(
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
                        .bind(to: self.streetFoodListReactor.action)
                        .disposed(by: cell.disposeBag)
                    cell.bind(stores: stores)
                    
                    self.streetFoodListReactor.state
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
                        withReuseIdentifier: StreetFoodListStoreCell.registerId,
                        for: indexPath
                    ) as? StreetFoodListStoreCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(store: store)
                    return cell
                    
                case .advertisement(let advertisement):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StreetFoodListAdvertisementCell.registerId,
                        for: indexPath
                    ) as? StreetFoodListAdvertisementCell else { return BaseCollectionViewCell() }
                    
                    cell.bind(advertisement: advertisement)
                    return cell
                }
        })
        
        self.streetFoodStoreCollectionViewDataSource.configureSupplementaryView
        = { _, collectionView, kind, indexPath -> UICollectionReusableView in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: StreetFoodListHeaderView.registerId,
                    for: indexPath
                ) as? StreetFoodListHeaderView else { return UICollectionReusableView() }
                
                headerView.certificatedButton.rx.isCertificated
                    .map { Reactor.Action.tapCertificatedButton(isOnlyCertificated: $0) }
                    .bind(to: self.streetFoodListReactor.action)
                    .disposed(by: headerView.disposeBag)
                
                headerView.orderFilterButton.rx.orderType
                    .distinctUntilChanged()
                    .map { Reactor.Action.tapOrderButton($0) }
                    .bind(to: self.streetFoodListReactor.action)
                    .disposed(by: headerView.disposeBag)
                
                headerView.adBannerView.rootViewController = self
                
                self.streetFoodListReactor.state
                    .map { $0.category }
                    .distinctUntilChanged()
                    .asDriver(onErrorJustReturn: StreetFoodCategory.totalCategory)
                    .drive(headerView.rx.category)
                    .disposed(by: headerView.disposeBag)
                
                return headerView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
}

extension StreetFoodListViewController: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        if reason == NMFMapChangedByGesture {
            let mapLocation = CLLocation(
                latitude: mapView.cameraPosition.target.lat,
                longitude: mapView.cameraPosition.target.lng
            )

            if animated {
                self.streetFoodListReactor.action.onNext(.changeMapLocation(mapLocation))
            }
        }
    }
}

extension StreetFoodListViewController: WriteAddressDelegate {
    func onWriteSuccess(storeId: Int) {
        
    }
}
