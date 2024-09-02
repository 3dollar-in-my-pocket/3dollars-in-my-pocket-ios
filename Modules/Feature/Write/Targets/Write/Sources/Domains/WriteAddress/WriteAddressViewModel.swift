import Foundation
import CoreLocation
import Combine

import Networking
import Model
import Common
import AppInterface
import Log

public final class WriteAddressViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let moveMapCenter = PassthroughSubject<Location, Never>()
        let tapCurrentLocation = PassthroughSubject<Void, Never>()
        let tapSetAddress = PassthroughSubject<Void, Never>()
        let tapConfirmAddress = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .writeAddress
        let setNearStores = PassthroughSubject<[Location], Never>()
        let moveCamera = PassthroughSubject<Location, Never>()
        let setAddress = PassthroughSubject<String, Never>()
        let editLocation = PassthroughSubject<(address: String, location: Location), Never>()
        let error = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pushWriteDetail(WriteDetailViewModel)
        case presentConfirmPopup(AddressConfirmPopupViewModel)
        case dismiss
    }
    
    private struct State {
        var type: WriteAddressType = .write
        var address = ""
        var cameraPosition: Location?
    }
    
    public enum WriteAddressType {
        /// 작성하기로 진입
        case write
        
        /// 가게 수정으로 진입
        case edit
    }
    
    public struct Config {
        public let type: WriteAddressType
        public let address: String
        public let cameraPosition: Location
    }
    
    let input = Input()
    let output = Output()
    private var state: State
    private let mapService: MapServiceProtocol
    private let storeRepository: StoreRepository
    private let locationManager: LocationManagerProtocol
    private let logManager: LogManagerProtocol
    
    public init(
        config: Config? = nil,
        mapService: MapServiceProtocol = MapService(),
        storeRepository: StoreRepository = StoreRepositoryImpl(),
        locationManager: LocationManagerProtocol = LocationManager.shared,
        logManager: LogManagerProtocol = LogManager.shared
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
        
        self.mapService = mapService
        self.storeRepository = storeRepository
        self.locationManager = locationManager
        self.logManager = logManager
        
        super.init()
    }
    
    public override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: WriteAddressViewModel, _) in
                if let cameraPosition = owner.state.cameraPosition {
                    owner.output.moveCamera.send(cameraPosition)
                    owner.output.setAddress.send(owner.state.address)
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
            .asyncMap { owner, location in
                await owner.mapService.getAddressFromLocation(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let address):
                    owner.state.address = address
                    owner.output.setAddress.send(address)
                    
                case .failure(let error):
                    owner.output.error.send(error)
                }
            }
            .store(in: &cancellables)
        
        moveCamera
            .filter({ (owner: WriteAddressViewModel, _) in
                owner.state.type == .write
            })
            .asyncMap { owner, location in
                await owner.fetchAroundStores(cameraPosition: location)
            }
            .compactMapValue()
            .subscribe(output.setNearStores)
            .store(in: &cancellables)
            
        
        let currentLocation = input.tapCurrentLocation
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.sendClickCurrentLocationLog()
            })
            .flatMap { owner, _ in
                owner.locationManager.getCurrentLocationPublisher()
                    .catch { error -> AnyPublisher<CLLocation, Never> in
                        owner.output.error.send(error)
                        return Empty().eraseToAnyPublisher()
                    }
            }
            .share()
        
        currentLocation
            .withUnretained(self)
            .asyncMap { owner, location in
                await owner.mapService.getAddressFromLocation(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let address):
                    owner.state.address = address
                    owner.output.setAddress.send(address)
                    
                case .failure(let error):
                    owner.output.error.send(error)
                }
            }
            .store(in: &cancellables)
        
        currentLocation
            .map { location in
                Location(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            .handleEvents(receiveOutput: { [weak self] location in
                self?.state.cameraPosition = location
            })
            .subscribe(output.moveCamera)
            .store(in: &cancellables)
        
        currentLocation
            .withUnretained(self)
            .asyncMap { owner, location in
                let location = Location(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                
                return await owner.fetchAroundStores(cameraPosition: location)
            }
            .compactMapValue()
            .subscribe(output.setNearStores)
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
                    owner.isStoreExistedAround(location: cameraPosition)
                    
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
    
    private func isStoreExistedAround(location: Location) {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        Task {
            let result =  await storeRepository.isStoresExistedAround(
                distance: 10,
                mapLocation: clLocation
            )
            
            switch result {
            case .success(let response):
                if response.isExists {
                    presentConfirmPopup()
                } else {
                    pushWriteDetail(location: location)
                }
                
            case .failure(let error):
                output.error.send(error)
            }
        }
    }
    
    private func fetchAroundStores(cameraPosition: Location) async -> Result<[Location], Error> {
        let input = FetchAroundStoreInput(
            distanceM: 100,
            targetStores: ["BOSS_STORE", "USER_STORE"],
            sortType: "DISTANCE_ASC",
            size: 20,
            mapLatitude: cameraPosition.latitude,
            mapLongitude: cameraPosition.longitude
        )
        
        return await storeRepository.fetchAroundStores(
            input: input,
            latitude: cameraPosition.latitude,
            longitude: cameraPosition.longitude
        )
        .map { result in
            result.contents.map { storeDetail in
                return Model.Location(
                    latitude: storeDetail.store.location?.latitude ?? 0,
                    longitude: storeDetail.store.location?.longitude ?? 0
                )
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
    
    private func pushWriteDetail(location: Location) {
        guard let cameraPosition = state.cameraPosition else { return }
        let config = WriteDetailViewModel.WriteConfig(location: cameraPosition, address: state.address)
        let viewModel = WriteDetailViewModel(config: config)
        
        output.route.send(.pushWriteDetail(viewModel))
    }
}

extension WriteAddressViewModel {
    private func sendClickCurrentLocationLog() {
        logManager.sendEvent(LogEvent(
            screen: output.screenName,
            eventName: .clickCurrentLocation,
            extraParameters: [.address: state.address]
        ))
    }
    
    private func sendClickSetAddressLog(address: String) {
        logManager.sendEvent(LogEvent(
            screen: output.screenName,
            eventName: .clickSetAddress,
            extraParameters: [.address: state.address]
        ))
    }
}
