import UIKit
import Combine

import DesignSystem
import Networking
import Common
import NMapsMap

protocol WriteAddressDelegate: AnyObject {
    func onWriteSuccess(storeId: Int)
}

final class WriteAddressViewController: BaseViewController, WriteAddressCoordinator {
    weak var delegate: WriteAddressDelegate?
    private let writeAddressView = WriteAddressView()
    private let viewModel = WriteAddressViewModel(
        mapService: Networking.MapService(),
        storeService: Networking.StoreService(),
        locationManager: Common.LocationManager.shared,
        analyticsManager: AnalyticsManager.shared
    )
    private weak var coordinator: WriteAddressCoordinator?
    
    static func instance(delegate: WriteAddressDelegate) -> UINavigationController {
        let writeAddressVC = WriteAddressViewController(nibName: nil, bundle: nil).then {
            $0.delegate = delegate
            $0.tabBarItem = UITabBarItem(
                title: nil,
                image: DesignSystemAsset.Icons.writeSolid.image,
                tag: TabBarTag.write.rawValue
            )
        }
        
        return UINavigationController(rootViewController: writeAddressVC).then {
            $0.modalPresentationStyle = .overCurrentContext
            $0.isNavigationBarHidden = true
        }
    }
    
    override func loadView() {
        view = writeAddressView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coordinator = self
        setupMap()
        viewModel.input.tapCurrentLocation.send(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.viewWillAppear.send(())
    }
    
    override func bindEvent() {
        writeAddressView.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { owner, _ in
                owner.coordinator?.dismiss()
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        writeAddressView.addressButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.tapSetAddress)
            .store(in: &cancellables)
        
        writeAddressView.currentLocationButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.tapCurrentLocation)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.setNearStores
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, stores in
                owner.writeAddressView.setNearStores(stores: stores)
            }
            .store(in: &cancellables)
        
        viewModel.output.moveCamera
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, location in
                owner.writeAddressView.moveCamera(location: location)
            }
            .store(in: &cancellables)
        
        viewModel.output.setAddress
            .receive(on: DispatchQueue.main)
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
        
        viewModel.output.error
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, error in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .pushAddressDetail(let address, let location):
                    owner.coordinator?.goToWriteDetail(
                        address: address,
                        location: location
                    )
                    
                case .presentConfirmPopup(let address):
                    owner.coordinator?.presentConfirmPopup(address: address)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupMap() {
        writeAddressView.mapView.addCameraDelegate(delegate: self)
    }
}

extension WriteAddressViewController: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        if animated && reason == NMFMapChangedByGesture {
            let location = Location(
                latitude: mapView.cameraPosition.target.lat,
                longitude: mapView.cameraPosition.target.lng
            )
            
            viewModel.input.moveMapCenter.send(location)
        }
    }
}

extension WriteAddressViewController: WriteDetailDelegate {
    func onWriteSuccess(storeId: Int) {
        delegate?.onWriteSuccess(storeId: storeId)
    }
}

extension WriteAddressViewController: AddressConfirmPopupViewControllerDelegate {
    func onClickOk() {
        viewModel.input.tapConfirmAddress.send(())
    }
}
