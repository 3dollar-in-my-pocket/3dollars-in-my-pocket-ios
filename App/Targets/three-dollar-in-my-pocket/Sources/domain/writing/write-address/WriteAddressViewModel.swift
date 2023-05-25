import Foundation
import Combine

import Networking

final class WriteAddressViewModel {
    struct Input {
        let moveMapCenter = PassthroughSubject<Location, Never>()
        let tapCurrentLocation = PassthroughSubject<Void, Never>()
        let tapSetAddress = PassthroughSubject<Void, Never>()
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
    private var cancellables = Set<AnyCancellable>()
    private let mapService: Networking.MapServiceProtocol
    private let locationManager: CombineLocationManagerProtocol
    
    init(
        mapService: Networking.MapServiceProtocol,
        locationManager: CombineLocationManagerProtocol
    ) {
        self.mapService = mapService
        self.locationManager = locationManager
        
        bind()
    }
    
    private func bind() {
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
                owner.locationManager.getCurrentLocation()
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
    }
}
