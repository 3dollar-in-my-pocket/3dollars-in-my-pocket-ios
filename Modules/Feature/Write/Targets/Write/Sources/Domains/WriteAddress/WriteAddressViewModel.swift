import Foundation
import CoreLocation
import Combine

import Networking
import Model
import Common
import AppInterface

public final class WriteAddressViewModel: BaseViewModel {
    struct Input {
        let viewWillAppear = PassthroughSubject<Void, Never>()
        let moveMapCenter = PassthroughSubject<Location, Never>()
        let tapCurrentLocation = PassthroughSubject<Void, Never>()
        let tapSetAddress = PassthroughSubject<Void, Never>()
        let tapConfirmAddress = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let setNearStores = PassthroughSubject<[Location], Never>()
        let moveCamera = PassthroughSubject<Location, Never>()
        let setAddress = PassthroughSubject<String, Never>()
        let error = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pushWriteDetail(WriteDetailViewModel)
        case presentConfirmPopup(AddressConfirmPopupViewModel)
    }
    
    private struct State {
        var address = ""
        var cameraPosition: Location?
        let screen: AnalyticsScreen = .writeAddress
    }
    
    let input = Input()
    let output = Output()
    private var state = State()
    private let mapService: MapServiceProtocol
    private let storeService: StoreServiceProtocol
    private let locationManager: LocationManagerProtocol
    private let analyticsManager: AnalyticsManagerProtocol
    
    public init(
        mapService: MapServiceProtocol = MapService(),
        storeService: StoreServiceProtocol = StoreService(),
        locationManager: LocationManagerProtocol = LocationManager.shared
    ) {
        self.mapService = mapService
        self.storeService = storeService
        self.locationManager = locationManager
        self.analyticsManager = Environment.appModuleInterface.analyticsManager
        
        super.init()
    }
    
    public override func bind() {
        input.viewWillAppear
            .withUnretained(self)
            .sink { owner, _ in
                owner.analyticsManager.logPageView(
                    screen: owner.state.screen,
                    type: WriteAddressViewController.self
                )
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
                
                owner.isStoreExistedAround(location: cameraPosition)
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
            let result =  await storeService.isStoresExistedAround(
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
        
        return await storeService.fetchAroundStores(
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
        analyticsManager.logEvent(event: .clickCurrentLocation, screen: state.screen)
    }
    
    private func sendClickSetAddressLog(address: String) {
        analyticsManager.logEvent(event: .clickSetAddress(address: address), screen: state.screen)
    }
}
