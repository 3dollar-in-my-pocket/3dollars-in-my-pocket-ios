import Foundation
import CoreLocation
import Combine

import Networking

final class WriteAddressViewModel {
    struct Input {
        let moveMapCenter = PassthroughSubject<Location, Never>()
        let tapCurrentLocation = PassthroughSubject<Void, Never>()
        let tapSetAddress = PassthroughSubject<Void, Never>()
        let tapConfirmAddress = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let setNearStores = PassthroughSubject<[Store], Never>()
        let moveCamera = PassthroughSubject<Location, Never>()
        let setAddress = PassthroughSubject<String, Error>()
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
    }
    
    let input = Input()
    let output = Output()
    private let state = State()
    private var cancellables = Set<AnyCancellable>()
    private let mapService: Networking.MapServiceProtocol
    private let storeService: Networking.StoreServiceProtocol
    private let locationManager: CombineLocationManagerProtocol
    
    init(
        mapService: Networking.MapServiceProtocol,
        storeService: Networking.StoreServiceProtocol,
        locationManager: CombineLocationManagerProtocol
    ) {
        self.mapService = mapService
        self.storeService = storeService
        self.locationManager = locationManager
        
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
        
        
        let moveCamera = input.moveMapCenter
            .withUnretained(self)
            .share()
        
        moveCamera
            .flatMap { owner, location in
                owner.mapService.getAddressFromLocation(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
            }
            .subscribe(output.setAddress)
            .store(in: &cancellables)
        
        // TODO: 주변 가게 조회 API는 새로 나오면 조회
        
        input.moveMapCenter
            .subscribe(output.moveCamera)
            .store(in: &cancellables)
        
        let currentLocation = input.tapCurrentLocation
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.locationManager.getCurrentLocationPublisher()
            }
            .share()
        
        currentLocation
            .withUnretained(self)
            .flatMap { owner, location -> AnyPublisher<String, Error> in
                owner.mapService.getAddressFromLocation(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            .subscribe(output.setAddress)
            .store(in: &cancellables)
        
        currentLocation
            .assertNoFailure()
            .map { location in
                Location(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            .subscribe(output.moveCamera)
            .store(in: &cancellables)
        
        input.tapSetAddress
            .withUnretained(self)
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
            case .success(let isExisted):
                if isExisted {
                    output.route.send(
                        .pushAddressDetail(address: state.address, location: location)
                    )
                } else {
                    output.route.send(.presentConfirmPopup(address: state.address))
                }
                
            case .failure(let error):
                output.error.send(error)
            }
        }
    }
}
