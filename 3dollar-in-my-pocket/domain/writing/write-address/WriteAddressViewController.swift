import UIKit

import RxSwift
import NMapsMap
import ReactorKit

protocol WriteAddressDelegate: AnyObject {
    func onWriteSuccess(storeId: Int)
}

final class WriteAddressViewController: BaseVC, View, WriteAddressCoordinator {
    weak var delegate: WriteAddressDelegate?
    private let writeAddressView = WriteAddressView()
    private let writeAddressReactor = WriteAddressReactor(
        mapService: MapService(),
        storeService: StoreService(),
        locationManager: LocationManager.shared
    )
    private weak var coordinator: WriteAddressCoordinator?
    
    
    static func instance(delegate: WriteAddressDelegate) -> UINavigationController {
        let writeAddressVC = WriteAddressViewController(nibName: nil, bundle: nil).then {
            $0.delegate = delegate
        }
        
        return UINavigationController(rootViewController: writeAddressVC).then {
            $0.modalPresentationStyle = .overCurrentContext
            $0.isNavigationBarHidden = true
        }
    }
    
    override func loadView() {
        self.view = self.writeAddressView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.writeAddressReactor
        self.coordinator = self
        self.setupMap()
    }
    
    func bind(reactor: WriteAddressReactor) {
        self.writeAddressView.addressButton.rx.tap
            .do(onNext: { _ in
                GA.shared.logEvent(
                    event: .set_address_button_clicked,
                    page: .store_register_address_page
                )
            })
            .map { Reactor.Action.tapSetAddress }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.writeAddressView.currentLocationButton.rx.tap
            .do(onNext: { _ in
                GA.shared.logEvent(
                    event: .current_location_button_clicked,
                    page: .store_register_address_page
                )
            })
            .map { Reactor.Action.tapCurrentLocation }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.address }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(self.writeAddressView.addressLabel.rx.text)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.nearStores }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.writeAddressView.rx.nearStores)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .compactMap { $0.cameraPosition }
            .distinctUntilChanged({ oldPosition, newPosition in
                return oldPosition == newPosition
            })
            .debug()
            .asDriver(onErrorJustReturn: (0, 0))
            .drive(self.writeAddressView.rx.cameraPosition)
            .disposed(by: self.disposeBag)
        
    }
    
    override func bindEvent() {
        self.writeAddressView.closeButton.rx.tap
            .do(onNext: { _ in
                GA.shared.logEvent(
                    event: .close_button_clicked,
                    page: .store_register_address_page
                )
            })
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
                
        self.writeAddressReactor.pushWriteDetailPublisher
            .asDriver(onErrorJustReturn: ("", (0, 0)))
            .drive(onNext: { [weak self] (address, location) in
                self?.coordinator?.goToWriteDetail(address: address, location: location)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.writeAddressReactor.presentConfirmPopupPublisher
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] address in
                self?.coordinator?.presentConfirmPopup(address: address)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    private func setupMap() {
        self.writeAddressView.mapView.addCameraDelegate(delegate: self)
    }
}

extension WriteAddressViewController: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        if animated && reason == NMFMapChangedByGesture {
            self.writeAddressReactor.action.onNext(.moveMapCenter(
                latitude: mapView.cameraPosition.target.lat,
                longitude: mapView.cameraPosition.target.lng
            ))
        }
    }
}

extension WriteAddressViewController: WriteDetailDelegate {
    func onWriteSuccess(storeId: Int) {
        self.delegate?.onWriteSuccess(storeId: storeId)
    }
}

extension WriteAddressViewController: AddressConfirmPopupViewControllerDelegate {
    func onDismiss() {
        self.showRootDim(isShow: false)
    }
    
    func onClickOk() {
        self.showRootDim(isShow: false)
        self.writeAddressReactor.action.onNext(.tapConfirmAddress)
    }
}
