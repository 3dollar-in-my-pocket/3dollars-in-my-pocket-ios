import UIKit
import Combine

import DesignSystem
import Networking
import Common
import Model
import AppInterface

import NMapsMap

public final class WriteAddressViewController: BaseViewController {
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
        
        setupMap()
        viewModel.input.tapCurrentLocation.send(())
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.viewWillAppear.send(())
    }
    
    public override func bindEvent() {
        writeAddressView.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { owner, _ in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    public override func bindViewModelInput() {
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
    
    public override func bindViewModelOutput() {
        viewModel.output.setNearStores
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { owner, stores in
                owner.writeAddressView.setNearStores(locations: stores)
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
                case .pushWriteDetail(let viewModel):
                    owner.pushWriteDetail(viewModel)
                    
                case .presentConfirmPopup(let viewModel):
                    owner.presentConfirmPopup(viewModel)
                }
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
            let location = Model.Location(
                latitude: mapView.cameraPosition.target.lat,
                longitude: mapView.cameraPosition.target.lng
            )
            
            viewModel.input.moveMapCenter.send(location)
        }
    }
}
