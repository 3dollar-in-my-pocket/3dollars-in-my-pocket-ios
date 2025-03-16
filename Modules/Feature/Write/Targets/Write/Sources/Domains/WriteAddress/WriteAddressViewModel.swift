import Foundation
import CoreLocation
import Combine

import Networking
import Model
import Common
import AppInterface
import Log
import WriteInterface

public final class WriteAddressViewModel: BaseViewModel {
    enum Constant {
        static let maxDistance: Double = 100
    }
    
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let moveMapCenter = PassthroughSubject<CLLocation, Never>()
        let tapCurrentLocation = PassthroughSubject<Void, Never>()
        let tapSetAddress = PassthroughSubject<Void, Never>()
        let tapConfirmAddress = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .writeAddress
        let storesNearBy = PassthroughSubject<[LocationResponse], Never>()
        let moveCamera = PassthroughSubject<CLLocation, Never>()
        let address = PassthroughSubject<String, Never>()
        let editLocation = PassthroughSubject<(address: String, location: CLLocation), Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pushWriteDetail(WriteDetailViewModel)
        case presentConfirmPopup(AddressConfirmPopupViewModel)
        case dismiss
        case showErrorAlert(Error)
    }
    
    private struct State {
        var type: WriteAddressType = .write
        var address = ""
        var cameraPosition: CLLocation?
    }
    
    public struct Dependency {
        let mapRepository: MapRepository
        let storeRepository: StoreRepository
        let locationManager: LocationManagerProtocol
        let logManager: LogManagerProtocol
        
        public init(
            mapRepository: MapRepository = MapRepositoryImpl(),
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            locationManager: LocationManagerProtocol = LocationManager.shared,
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.mapRepository = mapRepository
            self.storeRepository = storeRepository
            self.locationManager = locationManager
            self.logManager = logManager
        }
    }
    
    let input = Input()
    let output = Output()
    private let dependency: Dependency
    private var state: State
    
    public init(
        config: WriteAddressViewModelConfig? = nil,
        dependency: Dependency = Dependency()
    ) {
        if let config {
            self.state = State(
                type: config.type,
                address: config.address,
                cameraPosition: config.cameraPosition
            )
        } else {
            self.state = State()
        }
        self.dependency = dependency
        super.init()
    }
    
    public override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: WriteAddressViewModel, _) in
                if let cameraPosition = owner.state.cameraPosition {
                    owner.output.moveCamera.send(cameraPosition)
                    owner.output.address.send(owner.state.address)
                } else {
                    owner.input.tapCurrentLocation.send(())
                }
            }
            .store(in: &cancellables)
        
        let moveCamera = input.moveMapCenter
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, location in
                owner.state.cameraPosition = location
            })
            .share()
        
        moveCamera
            .sink { (owner: WriteAddressViewModel, location: CLLocation) in
                owner.updateAddress(location: location)
            }
            .store(in: &cancellables)
        
        moveCamera
            .filter({ (owner: WriteAddressViewModel, _) in
                owner.state.type == .write
            })
            .sink(receiveValue: { (owner: WriteAddressViewModel, location: CLLocation) in
                owner.fetchAroundStores(cameraPosition: location)
            })
            .store(in: &cancellables)
        
        input.tapCurrentLocation
            .withUnretained(self)
            .sink { (owner: WriteAddressViewModel, _) in
                owner.sendClickCurrentLocationLog()
                
                Task {
                    do {
                        let currentLocation = try await owner.dependency.locationManager.getCurrentLocation()
                        owner.state.cameraPosition = currentLocation
                        owner.output.moveCamera.send(currentLocation)
                        owner.updateAddress(location: currentLocation)
                        owner.fetchAroundStores(cameraPosition: currentLocation)
                    } catch {
                        owner.output.route.send(.showErrorAlert(error))
                    }
                }
            }
            .store(in: &cancellables)
        
        input.tapSetAddress
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.sendClickSetAddressLog(address: owner.state.address)
            })
            .sink(receiveValue: { owner, _ in
                guard let cameraPosition = owner.state.cameraPosition else { return }
                
                switch owner.state.type {
                case .write:
                    owner.checkStoreExistedAround(location: cameraPosition)
                    
                case .edit:
                    owner.output.editLocation.send((owner.state.address, cameraPosition))
                    owner.output.route.send(.dismiss)
                }
            })
            .store(in: &cancellables)
        
        input.tapConfirmAddress
            .withUnretained(self)
            .sink { owner, _ in
                guard let cameraPosition = owner.state.cameraPosition else { return }
                owner.pushWriteDetail(location: cameraPosition)
            }
            .store(in: &cancellables)
    }
    
    private func checkStoreExistedAround(location: CLLocation) {
        Task {
            let result =  await dependency.storeRepository.isStoresExistedAround(
                distance: 10,
                mapLocation: location
            )
            
            switch result {
            case .success(let response):
                if response.isExists {
                    presentConfirmPopup()
                } else {
                    pushWriteDetail(location: location)
                }
                
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func updateAddress(location: CLLocation) {
        Task {
            let result = await dependency.mapRepository.getAddressFromLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            switch result {
            case .success(let address):
                state.address = address
                output.address.send(address)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func fetchAroundStores(cameraPosition: CLLocation) {
        let input = FetchAroundStoreInput(
            distanceM: Constant.maxDistance,
            targetStores: [.bossStore, .userStore],
            sortType: .distanceAsc,
            size: 20,
            mapLatitude: cameraPosition.coordinate.latitude,
            mapLongitude: cameraPosition.coordinate.longitude
        )
        
        Task {
            let result = await dependency.storeRepository.fetchAroundStores(input: input)
            
            switch result {
            case .success(let response):
                let locations = response.contents.compactMap { $0.store.location }
                output.storesNearBy.send(locations)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func presentConfirmPopup() {
        let config = AddressConfirmPopupViewModel.Config(address: state.address)
        let viewModel = AddressConfirmPopupViewModel(config: config)
        
        viewModel.output.onClickOk
            .subscribe(input.tapConfirmAddress)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentConfirmPopup(viewModel))
    }
    
    private func pushWriteDetail(location: CLLocation) {
        guard let cameraPosition = state.cameraPosition else { return }
        let cameraLocation = LocationResponse(
            latitude: cameraPosition.coordinate.latitude,
            longitude: cameraPosition.coordinate.longitude
        )
        let config = WriteDetailViewModel.WriteConfig(location: cameraLocation, address: state.address)
        let viewModel = WriteDetailViewModel(config: config)
        
        output.route.send(.pushWriteDetail(viewModel))
    }
}

extension WriteAddressViewModel {
    private func sendClickCurrentLocationLog() {
        dependency.logManager.sendEvent(LogEvent(
            screen: output.screenName,
            eventName: .clickCurrentLocation,
            extraParameters: [.address: state.address]
        ))
    }
    
    private func sendClickSetAddressLog(address: String) {
        dependency.logManager.sendEvent(LogEvent(
            screen: output.screenName,
            eventName: .clickSetAddress,
            extraParameters: [.address: state.address]
        ))
    }
}
