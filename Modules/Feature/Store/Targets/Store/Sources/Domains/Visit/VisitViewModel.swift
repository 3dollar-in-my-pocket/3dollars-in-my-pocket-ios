import Foundation
import Combine
import CoreLocation

import Common
import Model
import Networking
import Log

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
        let screenName: ScreenName = .visitStore
        let store: CurrentValueSubject<VisitableStore, Never>
        let distance = PassthroughSubject<Int, Never>()
        let canVisit = PassthroughSubject<Bool, Never>()
        let moveCamera = PassthroughSubject<CLLocation, Never>()
        let toast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        
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
    
    struct Config {
        let storeId: Int
        let store: VisitableStore
    }
    
    struct Dependency {
        let locationManager: LocationManagerProtocol
        let visitRepository: VisitRepository
        let logManager: LogManagerProtocol
        
        init(
            locationManager: LocationManagerProtocol = LocationManager.shared,
            visitRepository: VisitRepository = VisitRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.locationManager = locationManager
            self.visitRepository = visitRepository
            self.logManager = logManager
        }
    }
    
    let input = Input()
    let output: Output
    private var state = State()
    private let config: Config
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(store: .init(config.store))
        self.config = config
        self.dependency = dependency
    }
    
    override func bind() {
        input.viewWillAppear
            .first()
            .withUnretained(self)
            .sink { (owner: VisitViewModel, _) in
                owner.setupTimer()
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
                owner.sendClickVisitLog(type: type)
            }
            .store(in: &cancellables)
    }
    
    private func setupTimer() {
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .prepend(Date())
            .withUnretained(self)
            .sink(receiveValue: { (owner: VisitViewModel, _) in
                owner.fetchLocation()
            })
            .store(in: &cancellables)
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
                latitude: config.store.location?.latitude ?? 0,
                longitude: config.store.location?.longitude ?? 0
            )
            let distance = Int(location.distance(from: storeLocation))
            
            state.currentLocation = location
            output.distance.send(distance)
            output.canVisit.send(distance <= Constent.maxVisitableDistance)
        }
    }
    
    private func visitStore(type: VisitType) {
        Task {
            let input = VisitStoreRequestInput(storeId: config.storeId, visitType: type)
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
