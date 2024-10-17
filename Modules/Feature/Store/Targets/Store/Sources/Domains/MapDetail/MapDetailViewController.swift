import UIKit
import MapKit

import Common
import DesignSystem
import Model

public final class MapDetailViewController: BaseViewController {
    private let mapDetailView = MapDetailView()
    private let viewModel: MapDetailViewModel
    
    public init(viewModel: MapDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        self.view = mapDetailView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func bindEvent() {
        mapDetailView.closeButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: MapDetailViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    public override func bindViewModelInput() {
        mapDetailView.navigationButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapNavigation)
            .store(in: &cancellables)
    }
    
    public override func bindViewModelOutput() {
        viewModel.output.storeLocation
            .main
            .withUnretained(self)
            .sink { (owner: MapDetailViewController, location) in
                owner.mapDetailView.bind(location: location)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: MapDetailViewController, route) in
                switch route {
                case .presentNavigationActionSheet:
                    owner.presentNavigationModal()
                case .navigateAppleMap(let location):
                    owner.navigateAppleMap(location: location)
                }
            }
            .store(in: &cancellables)
    }
    
    private func presentNavigationModal() {
        let alertController = UIAlertController(
            title: Strings.NavigationBottomSheet.title,
            message: Strings.NavigationBottomSheet.message,
            preferredStyle: .actionSheet
        )
        let naverAction = UIAlertAction(
            title: Strings.NavigationBottomSheet.Action.naverMap,
            style: .default
        ) { [weak self] _ in
            self?.viewModel.input.didTapNavigationAction.send(.naver)
        }
        let kakaoAction = UIAlertAction(
            title: Strings.NavigationBottomSheet.Action.kakaoMap,
            style: .default
        ) { [weak self] _ in
            self?.viewModel.input.didTapNavigationAction.send(.kakao)
        }
        let appleAction = UIAlertAction(
            title: Strings.NavigationBottomSheet.Action.appleMap,
            style: .default
        ) { [weak self] _ in
            self?.viewModel.input.didTapNavigationAction.send(.apple)
        }
        let cancelAction = UIAlertAction(title: Strings.NavigationBottomSheet.Action.cancel, style: .cancel)
        
        alertController.addAction(naverAction)
        alertController.addAction(kakaoAction)
        alertController.addAction(appleAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func navigateAppleMap(location: LocationResponse) {
        let latitude: CLLocationDegrees = location.latitude
        let longitude: CLLocationDegrees = location.longitude
        let destinationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: destinationCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = "목적지"
        
        let options = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,  // 운전 모드
            MKLaunchOptionsShowsTrafficKey: true  // 교통 상황 표시
        ] as [String : Any]
        
        mapItem.openInMaps(launchOptions: options)
    }
}
