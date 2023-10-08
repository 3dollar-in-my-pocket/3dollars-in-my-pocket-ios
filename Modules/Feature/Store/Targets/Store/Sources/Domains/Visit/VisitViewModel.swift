import Foundation
import Combine
import CoreLocation

import Common
import Model
import Networking

final class VisitViewModel: BaseViewModel {
    enum Constent {
        static let defaultLocation = CLLocation(latitude: 37.497941, longitude: 127.027616)
        static let maxVisitableDistance = 100
    }
    
    struct Input {
        let viewWillAppear = PassthroughSubject<Void, Never>()
        let didTapCurrentLocation = PassthroughSubject<Void, Never>()
        let didTapVisit = PassthroughSubject<VisitType, Never>()
    }
    
    struct Output {
        let store: CurrentValueSubject<VisitableStore, Never>
        let distance = PassthroughSubject<Int, Never>()
        let canVisit = PassthroughSubject<Bool, Never>()
        let moveCamera = PassthroughSubject<CLLocation, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
        
        // 뷰모델 이벤트 전달용
        let onSuccessVisit = PassthroughSubject<Void, Never>()
    }
    
    enum Route {
        case dismiss
    }
    
    struct State {
        var currentLocation: CLLocation?
    }
    
    struct Config {
        let storeId: Int
        let store: VisitableStore
        
        public init(storeId: Int, store: VisitableStore) {
            self.storeId = storeId
            self.store = store
        }
    }
    
    let input = Input()
    let output: Output
    private var state = State()
    private let config: Config
    private let locationManager: LocationManagerProtocol
    private let visitService: VisitServiceProtocol
    
    init(
        config: Config,
        locationManager: LocationManagerProtocol = LocationManager.shared,
        visitService: VisitServiceProtocol = VisitService()
    ) {
        self.output = Output(store: .init(config.store))
        self.config = config
        self.locationManager = locationManager
        self.visitService = visitService
    }
    
    override func bind() {
        input.viewWillAppear
            .withUnretained(self)
            .sink { (owner: VisitViewModel, _) in
                owner.trackingLocation()
            }
            .store(in: &cancellables)
        
        input.didTapCurrentLocation
            .withUnretained(self)
            .sink { (owner: VisitViewModel, _) in
                guard let currentLocation = owner.state.currentLocation else { return }
                owner.output.moveCamera.send(currentLocation)
            }
            .store(in: &cancellables)
        
        input.didTapVisit
            .withUnretained(self)
            .sink { (owner: VisitViewModel, type: VisitType) in
                owner.visitStore(type: type)
            }
            .store(in: &cancellables)
    }
    
    private func trackingLocation() {
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .withUnretained(self)
            .flatMap { (owner: VisitViewModel, _) in
                return owner.locationManager.getCurrentLocationPublisher()
                    .catch { error -> AnyPublisher<CLLocation, Never> in
                        owner.state.currentLocation = Constent.defaultLocation
                        // TODO: 권한 에러 발생 필요
                        
                        return Just(Constent.defaultLocation).eraseToAnyPublisher()
                    }
            }
            .withUnretained(self)
            .sink { (owner: VisitViewModel, location: CLLocation) in
                let storeLocation = CLLocation(
                    latitude: owner.config.store.storeLocation?.latitude ?? 0,
                    longitude: owner.config.store.storeLocation?.longitude ?? 0
                )
                let distance = Int(location.distance(from: storeLocation))
                
                owner.state.currentLocation = location
                owner.output.distance.send(distance)
                owner.output.canVisit.send(distance <= Constent.maxVisitableDistance)
            }
            .store(in: &cancellables)
    }
    
    private func fetchCurrentLocation() {
        
    }
    
    private func visitStore(type: VisitType) {
        Task {
            let result = await visitService.visitStore(storeId: config.storeId, type: type)
            
            switch result {
            case .success(_):
                output.onSuccessVisit.send(())
                output.route.send(.dismiss)
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
}
