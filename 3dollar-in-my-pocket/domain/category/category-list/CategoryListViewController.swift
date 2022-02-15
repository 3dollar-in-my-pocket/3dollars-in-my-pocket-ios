import UIKit

import RxSwift
import ReactorKit
import NMapsMap

final class CategoryListViewController: BaseVC, CategoryListCoordinator, View {
    private let categoryListView = CategoryListView()
    private let categoryListReactor: CategoryListReactor
    private weak var coordinator: CategoryListCoordinator?
  
    init(category: StoreCategory) {
        self.categoryListReactor = CategoryListReactor(
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
  
    static func instance(category: StoreCategory) -> CategoryListViewController {
        return CategoryListViewController(category: category)
    }
  
    override func loadView() {
        self.view = self.categoryListView
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.categoryListReactor
        self.setupMap()
        self.categoryListView.adBannerView.rootViewController = self
        self.categoryListReactor.action.onNext(.viewDidLoad)
    }
  
    override func bindEvent() {
        self.categoryListView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.popup()
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: CategoryListReactor) {
        // Bind Action
        self.categoryListView.currentLocationButton.rx.tap
            .map { Reactor.Action.tapCurrentLocationButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.categoryListView.orderFilterButton.rx.orderType
            .map { Reactor.Action.tapOrderButton($0) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.categoryListView.certificatedButton.rx.tap
            .map { Reactor.Action.tapCertificatedButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.category }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: .BUNGEOPPANG)
            .drive(self.categoryListView.rx.category)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.cameraPosition }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: CLLocation(latitude: 0, longitude: 0))
            .drive(self.categoryListView.rx.cameraPosition)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.storeCellTypes }
            .distinctUntilChanged()
            .do(onNext: { [weak self] storeCellTypes in
                self?.categoryListView.calculateTableViewHeight(storeCellTypes: storeCellTypes)
                self?.categoryListView.setMarkers(storeCellTypes: storeCellTypes)
            })
            .asDriver(onErrorJustReturn: [])
            .drive(
                self.categoryListView.storeTableView.rx.items
            ) { tableView, row, storeCellType -> UITableViewCell in
                let indexPath = IndexPath(row: row, section: 0)
                
                switch storeCellType {
                case .store(let store):
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: CategoryListStoreCell.registerId,
                        for: indexPath
                    ) as? CategoryListStoreCell else { return BaseTableViewCell() }
                    
                    cell.bind(store: store)
                    return cell
                    
                case .advertisement(let advertisement):
                    guard let cell = tableView.dequeueReusableCell(
                        withIdentifier: CategoryListAdvertisementCell.registerId,
                        for: indexPath
                    ) as? CategoryListAdvertisementCell else { return BaseTableViewCell() }
                    
                    cell.bind(advertisement: advertisement)
                    return cell
                case .empty:
                    return BaseTableViewCell()
                }
            }
            .disposed(by: self.disposeBag)
    }
  
    private func setupMap() {
        self.categoryListView.mapView.addCameraDelegate(delegate: self)
    }
}

extension CategoryListViewController: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        if reason == NMFMapChangedByGesture {
            let mapLocation = CLLocation(
                latitude: mapView.cameraPosition.target.lat,
                longitude: mapView.cameraPosition.target.lng
            )
            
        
            self.categoryListReactor.action.onNext(.changeMapLocation(mapLocation))
        }
    }
}
