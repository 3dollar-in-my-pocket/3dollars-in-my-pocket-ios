import UIKit

import Base
import RxSwift
import RxDataSources
import ReactorKit

final class StreetFoodListViewController: BaseViewController, StreetFoodListCoordinator, View {
    private let streetFoodListView = StreetFoodListView()
    private let streetFoodListReactor: StreetFoodListReactor
    private weak var coordinator: StreetFoodListCoordinator?
    private var streetFoodStoreCollectionViewDataSource:
    RxCollectionViewSectionedReloadDataSource<StreetFoodListSectionModel>!
  
    init(category: StreetFoodCategory) {
        self.streetFoodListReactor = StreetFoodListReactor(
            category: category,
            storeService: StoreService(),
            advertisementService: AdvertisementService(),
            locationManager: LocationManager.shared
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    static func instance(category: StreetFoodCategory) -> UINavigationController {
        let viewController = StreetFoodListViewController(category: category).then {
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
  
    override func loadView() {
        self.view = self.streetFoodListView
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.streetFoodListReactor
//        self.categoryListView.adBannerView.rootViewController = self
        self.streetFoodListReactor.action.onNext(.viewDidLoad)
    }
  
    override func bindEvent() {
        self.streetFoodListReactor.pushStoreDetailPublisher
            .asDriver(onErrorJustReturn: -1)
            .drive(onNext: { [weak self] storeId in
                self?.coordinator?.pushStoreDetail(storeId: storeId)
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
        
//        self.categoryListView.currentLocationButton.rx.tap
//            .map { Reactor.Action.tapCurrentLocationButton }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//
//        self.categoryListView.orderFilterButton.rx.orderType
//            .map { Reactor.Action.tapOrderButton($0) }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//
//        self.categoryListView.certificatedButton.rx.isCertificated
//            .map { Reactor.Action.tapCertificatedButton(isOnlyCertificated: $0) }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//
//        self.categoryListView.storeTableView.rx.itemSelected
//            .map { Reactor.Action.tapStore(index: $0.row) }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { state -> [StreetFoodListSectionModel] in
                let mapSection = StreetFoodListSectionModel(stores: state.stores)
                let storeSection = StreetFoodListSectionModel(
                    stores: state.stores,
                    advertisement: state.advertisement
                )
                
                return [mapSection] + [storeSection]
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.streetFoodListView.collectionView.rx.items(
                dataSource: self.streetFoodStoreCollectionViewDataSource
            ))
            .disposed(by: self.disposeBag)
        
//        reactor.state
//            .map { $0.category }
//            .distinctUntilChanged()
//            .asDriver(onErrorJustReturn: .BUNGEOPPANG)
//            .drive(self.categoryListView.rx.category)
//            .disposed(by: self.disposeBag)
//
//        reactor.state
//            .compactMap { $0.cameraPosition }
//            .distinctUntilChanged()
//            .asDriver(onErrorJustReturn: CLLocation(latitude: 0, longitude: 0))
//            .drive(self.categoryListView.rx.cameraPosition)
//            .disposed(by: self.disposeBag)
//
//        reactor.state
//            .map { ($0.storeCellTypes, $0.isOnlyCertificated) }
//            .map { [weak self] storeCellTypes, isOnlyCertificated -> [StoreCellType] in
//                return self?.filterCertificated(
//                    storeCellTypes: storeCellTypes,
//                    isOnlyCertificated: isOnlyCertificated
//                ) ?? []
//            }
//            .distinctUntilChanged()
//            .do(onNext: { [weak self] storeCellTypes in
//                self?.categoryListView.calculateTableViewHeight(storeCellTypes: storeCellTypes)
//                self?.categoryListView.setMarkers(storeCellTypes: storeCellTypes)
//            })
//            .asDriver(onErrorJustReturn: [])
//            .drive(
//                self.categoryListView.storeTableView.rx.items
//            ) { tableView, row, storeCellType -> UITableViewCell in
//                let indexPath = IndexPath(row: row, section: 0)
//
//                switch storeCellType {
//                case .store(let store):
//                    guard let cell = tableView.dequeueReusableCell(
//                        withIdentifier: CategoryListStoreCell.registerId,
//                        for: indexPath
//                    ) as? CategoryListStoreCell else { return BaseTableViewCell() }
//                    guard let store = store as? Store else { return BaseTableViewCell() }
//
//                    cell.bind(store: store)
//                    return cell
//
//                case .advertisement(let advertisement):
//                    guard let cell = tableView.dequeueReusableCell(
//                        withIdentifier: CategoryListAdvertisementCell.registerId,
//                        for: indexPath
//                    ) as? CategoryListAdvertisementCell else { return BaseTableViewCell() }
//
//                    cell.bind(advertisement: advertisement)
//                    return cell
//                case .empty:
//                    guard let cell = tableView.dequeueReusableCell(
//                        withIdentifier: CategoryListEmptyCell.registerId,
//                        for: indexPath
//                    ) as? CategoryListEmptyCell else { return BaseTableViewCell() }
//
//                    return cell
//                }
//            }
//            .disposed(by: self.disposeBag)
    }
    
    private func setupDateSource() {
        self.streetFoodStoreCollectionViewDataSource
        = RxCollectionViewSectionedReloadDataSource<StreetFoodListSectionModel>(
            configureCell: { dataSource, collectionView, indexPath, item in
                switch item {
                case .map(let stores):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StreetFoodListMapCell.registerId,
                        for: indexPath
                    ) as? StreetFoodListMapCell else { return BaseCollectionViewCell() }
                    
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
                    
                    return cell
                    
                case .advertisement(let advertisement):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: StreetFoodListAdvertisementCell.registerId,
                        for: indexPath
                    ) as? StreetFoodListAdvertisementCell else { return BaseCollectionViewCell() }
                    
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
                
                return headerView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
    
    private func filterCertificated(
        storeCellTypes: [StoreCellType],
        isOnlyCertificated: Bool
    ) -> [StoreCellType] {
        var newStoreCellTypes: [StoreCellType] = []
        
        if isOnlyCertificated {
            for storeCellType in storeCellTypes {
                if case .store(let store) = storeCellType {
                    guard let store = store as? Store else { return storeCellTypes }
                    
                    if store.visitHistory.isCertified {
                        newStoreCellTypes.append(storeCellType)
                    }
                } else {
                    newStoreCellTypes.append(storeCellType)
                }
            }
            return newStoreCellTypes
        } else {
            return storeCellTypes
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
