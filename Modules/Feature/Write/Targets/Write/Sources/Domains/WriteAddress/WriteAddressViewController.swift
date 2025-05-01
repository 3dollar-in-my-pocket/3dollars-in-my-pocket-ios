import UIKit
import Combine

import DesignSystem
import Networking
import Common
import Model
import Log

import NMapsMap
import CombineCocoa

public final class WriteAddressViewController: BaseViewController {
    public override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    var onSuccessWrite: ((Int) -> ())?
    private let writeAddressView = WriteAddressView()
    private let viewModel: WriteAddressViewModel
    
    public init(viewModel: WriteAddressViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem = UITabBarItem(
            title: nil,
            image: DesignSystemAsset.Icons.writeSolid.image,
            tag: TabBarTag.write.rawValue
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = writeAddressView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setupMap()
        viewModel.input.viewDidLoad.send(())
    }
    
    private func bind() {
        // Event
        writeAddressView.closeButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapClose)
            .store(in: &cancellables)
        
        // Input
        writeAddressView.addressButton.tapPublisher
            .throttleClick()
            .mapVoid
            .subscribe(viewModel.input.tapSetAddress)
            .store(in: &cancellables)
        
        writeAddressView.currentLocationButton.tapPublisher
            .throttleClick()
            .mapVoid
            .subscribe(viewModel.input.tapCurrentLocation)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.storesNearBy
            .main
            .withUnretained(self)
            .sink { (owner: WriteAddressViewController, stores: [LocationResponse]) in
                owner.writeAddressView.setNearStores(locations: stores)
            }
            .store(in: &cancellables)
        
        viewModel.output.moveCamera
            .main
            .withUnretained(self)
            .sink { owner, location in
                owner.writeAddressView.moveCamera(location: location)
            }
            .store(in: &cancellables)
        
        viewModel.output.address
            .main
            .withUnretained(self)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.showErrorAlert(error: error)
                case .finished:
                    break
                }
            } receiveValue: { owner, address in
                owner.writeAddressView.setAddress(address)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner: WriteAddressViewController, route: WriteAddressViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func setupMap() {
        writeAddressView.mapView.addCameraDelegate(delegate: self)
    }
    
    private func pushWriteDetail(_ viewModel: WriteDetailViewModel) {
        let viewController = WriteDetailViewController(viewModel: viewModel)
        viewController.onSuccessWrite = { [weak self] storeId in
            self?.onSuccessWrite?(storeId)
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentConfirmPopup(_ viewModel: AddressConfirmPopupViewModel) {
        let viewController = AddressConfirmPopupViewController(viewModel: viewModel)
        
        navigationController?.present(viewController, animated: true)
    }
}

extension WriteAddressViewController: NMFMapViewCameraDelegate {
    public func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        if animated && reason == NMFMapChangedByGesture {
            let location = CLLocation(
                latitude: mapView.cameraPosition.target.lat,
                longitude: mapView.cameraPosition.target.lng
            )
            
            viewModel.input.moveMapCenter.send(location)
        }
    }
}

// MARK: Route
extension WriteAddressViewController {
    private func handleRoute(_ route: WriteAddressViewModel.Route) {
        switch route {
        case .pushWriteDetail(let viewModel):
            pushWriteDetail(viewModel)
        case .presentConfirmPopup(let viewModel):
            presentConfirmPopup(viewModel)
        case .dismiss:
            dismiss(animated: true)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}
