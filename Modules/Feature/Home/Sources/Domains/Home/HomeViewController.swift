import UIKit

import Common
import DesignSystem
import NMapsMap

public final class HomeViewController: BaseViewController {
    private let homeView = HomeView()
    private let viewModel = HomeViewModel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        // TODO: 태그 정의 필요
        tabBarItem = UITabBarItem(title: nil, image: DesignSystemAsset.Icons.homeSolid.image, tag: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func instance() -> HomeViewController {
        return HomeViewController()
    }
    
    public override func loadView() {
        view = homeView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.input.viewDidLoad.send(())
        homeView.collectionView.dataSource = self
        homeView.mapView.addCameraDelegate(delegate: self)
    }
    
    public override func bindViewModelInput() {
//        let selectCategory = PassthroughSubject<Category?, Never>()
//        let searchByAddress = PassthroughSubject<CLLocation, Never>()
//        let selectStore = PassthroughSubject<Int, Never>()
//        let onTapStore = PassthroughSubject<Int, Never>()
//        let onTapVisitButton = PassthroughSubject<Int, Never>()
//        let onTapMarker = PassthroughSubject<Int, Never>()
//        let onTapCurrentMarker = PassthroughSubject<Void, Never>()
        
        homeView.sortingButton.sortTypePublisher
            .subscribe(viewModel.input.onToggleSort)
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
    }
    
    public override func bindViewModelOutput() {
        viewModel.output.isHiddenResearchButton
            .withUnretained(self)
            .sink { owner, isHidden in
                owner.homeView.setHiddenResearchButton(isHidden: isHidden)
            }
            .store(in: &cancellables)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HomeCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        
        return cell
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
