import Foundation
import Combine
import CoreLocation

import Common
import Model
import Networking
import Log

public final class VisitViewModel: BaseViewModel {
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
        let screenName: ScreenName = .visitStore
        let store = CurrentValueSubject<StoreDetailResponse?, Never>(nil)
        let distance = PassthroughSubject<Int, Never>()
        let canVisit = PassthroughSubject<Bool, Never>()
        let moveCamera = PassthroughSubject<CLLocation, Never>()
        let toast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let isLoading = PassthroughSubject<Bool, Never>()
        
        // 뷰모델 이벤트 전달용
        let onSuccessVisit = PassthroughSubject<Void, Never>()
    }
    
    enum Route {
        case dismiss
        case showErrorAlert(Error)
    }
    
    struct State {
        var currentLocation: CLLocation?
    }
    
    public struct Config {
        let storeId: String
        
        public init(storeId: String) {
            self.storeId = storeId
        }
    }
    
    public struct Dependency {
        let locationManager: LocationManagerProtocol
        let storeRepository: StoreRepository
        let visitRepository: VisitRepository
        let logManager: LogManagerProtocol
        
        public init(
            locationManager: LocationManagerProtocol = LocationManager.shared,
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            visitRepository: VisitRepository = VisitRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.locationManager = locationManager
            self.storeRepository = storeRepository
            self.visitRepository = visitRepository
            self.logManager = logManager
        }
    }
    
    let input = Input()
    let output = Output()
    private var state = State()
    private let config: Config
    private let dependency: Dependency
    
    public init(config: Config, dependency: Dependency = Dependency()) {
        self.config = config
        self.dependency = dependency
        
        super.init()
    }
    
    public override func bind() {
        input.viewWillAppear
            .first()
            .sink { [weak self] in
                self?.fetchDatas()
                self?.setupTimer()
            }
            .store(in: &cancellables)
        
        input.didTapCurrentLocation
            .sink { [weak self] _ in
                guard let self, let currentLocation = state.currentLocation else { return }
                output.moveCamera.send(currentLocation)
            }
            .store(in: &cancellables)
        
        input.didTapVisit
            .sink { [weak self] (type: VisitType) in
                self?.visitStore(type: type)
                self?.sendClickVisitLog(type: type)
            }
            .store(in: &cancellables)
    }
    
    private func fetchDatas() {
        Task {
            do {
                output.isLoading.send(true)
                let input = FetchStoreInput(storeId: config.storeId, includes: [])
                let store = try await dependency.storeRepository.fetcXhStore(input: input).get()
                let location = try await dependency.locationManager.getCurrentLocation()
                
                state.currentLocation = location
                output.store.send(store)
                updateDistance()
                output.isLoading.send(false)
            } catch {
                output.route.send(.showErrorAlert(error))
                output.isLoading.send(false)
            }
        }
    }
    
    private func setupTimer() {
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink(receiveValue: { [weak self] _ in
                self?.fetchLocation()
            })
            .store(in: &cancellables)
    }
    
    private func updateDistance() {
        guard let store = output.store.value,
              let currentLocation = state.currentLocation else { return }
        
        let storeLocation = CLLocation(
            latitude: store.location?.latitude ?? 0,
            longitude: store.location?.longitude ?? 0
        )
        let distance = Int(currentLocation.distance(from: storeLocation))
        
        output.distance.send(distance)
        output.canVisit.send(distance <= Constent.maxVisitableDistance)
    }
    
    private func fetchLocation() {
        Task {
            var location: CLLocation
            do {
                location = try await dependency.locationManager.getCurrentLocation()
            } catch {
                location = Constent.defaultLocation
            }
            
            
            let storeLocation = CLLocation(
                latitude: output.store.value?.location?.latitude ?? 0,
                longitude: output.store.value?.location?.longitude ?? 0
            )
            let distance = Int(location.distance(from: storeLocation))
            
            state.currentLocation = location
            output.distance.send(distance)
            output.canVisit.send(distance <= Constent.maxVisitableDistance)
        }
    }
    
    private func visitStore(type: VisitType) {
        guard let storeId = Int(config.storeId) else { return }
        Task {
            let input = VisitStoreRequestInput(storeId: storeId, visitType: type)
            let result = await dependency.visitRepository.visitStore(input: input)
            
            switch result {
            case .success(_):
                output.onSuccessVisit.send(())
                output.toast.send(Strings.Visit.resultMessage)
                output.route.send(.dismiss)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}

// MARK: Log
extension VisitViewModel {
    private func sendClickVisitLog(type: VisitType) {
        let eventName: EventName
        
        switch type {
        case .exists:
            eventName = .clickVisitSuccess
        case .notExists:
            eventName = .clickVisitFail
        case .unknown:
            return
        }
        
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: eventName,
            extraParameters: [.storeId: config.storeId]
        ))
    }
}
