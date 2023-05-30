import Foundation
import CoreLocation
import Combine

import Networking
import Common

final class WriteAddressViewModel {
    struct Input {
        let viewWillAppear = PassthroughSubject<Void, Never>()
        let moveMapCenter = PassthroughSubject<Location, Never>()
        let tapCurrentLocation = PassthroughSubject<Void, Never>()
        let tapSetAddress = PassthroughSubject<Void, Never>()
        let tapConfirmAddress = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let setNearStores = PassthroughSubject<[Store], Never>()
        let moveCamera = PassthroughSubject<Location, Never>()
        let setAddress = PassthroughSubject<String, Never>()
        let error = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pushAddressDetail(address: String, location: Location)
        case presentConfirmPopup(address: String)
    }
    
    private struct State {
        var address = ""
        var nearStores: [Store] = []
        var cameraPosition: Location?
        let screen: AnalyticsScreen = .writeAddress
    }
    
    let input = Input()
    let output = Output()
    private var state = State()
    private var cancellables = Set<AnyCancellable>()
    private let mapService: Networking.MapServiceProtocol
    private let storeService: Networking.StoreServiceProtocol
    private let locationManager: Common.LocationManagerProtocol
    private let analyticsManager: AnalyticsManagerProtocol
    
    init(
        mapService: Networking.MapServiceProtocol,
        storeService: Networking.StoreServiceProtocol,
        locationManager: Common.LocationManagerProtocol,
        analyticsManager: AnalyticsManagerProtocol
    ) {
        self.mapService = mapService
        self.storeService = storeService
        self.locationManager = locationManager
        self.analyticsManager = analyticsManager
        
        bind()
    }
    
    private func bind() {
        // TODO: 주변 가게 조회 API 나오면 적용 예정 (아래 Reactor 함수 참고)
        // 1. 카메라 움직였을 때 조회하여 주변에 마커 찍어주기
        // 2. 내 위치 버튼 눌렀을 때도 동일하게 적용
//        private func fetchNearStores(latitude: Double, longitude: Double) -> Observable<Mutation> {
//            return self.storeService.searchNearStores(
//                currentLocation: nil,
//                mapLocation: CLLocation(latitude: latitude, longitude: longitude),
//                distance: 200,
//                category: nil,
//                orderType: nil
//            )
//            .map { .setNearStores(stores: $0.map(Store.init)) }
//            .catchError { .just(.showErrorAlert($0)) }
//        }
        
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
                
                owner.output.route.send(.pushAddressDetail(address: owner.state.address, location: cameraPosition))
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
                    output.route.send(.presentConfirmPopup(address: state.address))
                } else {
                    output.route.send(
                        .pushAddressDetail(address: state.address, location: location)
                    )
                }
                
            case .failure(let error):
                output.error.send(error)
            }
        }
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
