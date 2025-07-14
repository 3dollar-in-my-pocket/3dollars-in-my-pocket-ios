import Foundation
import CoreLocation
import Combine

import Networking
import Model
import Common
import AppInterface
import Log
import WriteInterface

extension WriteAddressViewModel {
    enum Constant {
        static let maxDistance: Double = 100
    }
    
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let moveMapCenter = PassthroughSubject<CLLocation, Never>()
        let didTapCurrentLocation = PassthroughSubject<Void, Never>()
        let didTapSetAddress = PassthroughSubject<Void, Never>()
        let didTapBossButton = PassthroughSubject<Void, Never>()
        let didTapConfirmAddress = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .writeAddress
        let cameraPosition = PassthroughSubject<CLLocation, Never>()
        let address = CurrentValueSubject<String, Never>("")
//        let editLocation = PassthroughSubject<(address: String, location: CLLocation), Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pushWriteDetail(WriteDetailViewModel)
        case presentConfirmPopup(AddressConfirmBottomSheetViewModel)
        case presentBossAppBottomSheet(BossAppBottomSheetViewModel)
        case showErrorAlert(Error)
    }
    
    private struct State {
        var cameraPosition: CLLocation? = nil
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
}

public final class WriteAddressViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let dependency: Dependency
    private var state = State()
    
    public init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        super.init()
    }
    
    public override func bind() {
        input.viewDidLoad
            .sink { [weak self] _ in
                self?.fetchCurrentLocation()
            }
            .store(in: &cancellables)
        
        input.moveMapCenter
            .sink(receiveValue: { [weak self] location in
                self?.state.cameraPosition = location
                self?.updateAddress(location: location)
            })
            .store(in: &cancellables)
        
        input.didTapCurrentLocation
            .sink { [weak self] _ in
                self?.sendClickCurrentLocationLog()
                self?.fetchCurrentLocation()
            }
            .store(in: &cancellables)
        
        input.didTapSetAddress
            .sink { [weak self] _ in
                guard let self,
                      let cameraPosition = state.cameraPosition else { return }
                
                sendClickSetAddressLog(address: output.address.value)
                checkStoreExistedAround(location: cameraPosition)
            }
            .store(in: &cancellables)
        
        input.didTapBossButton
            .sink { [weak self] _ in
                let viewModel = BossAppBottomSheetViewModel()
                self?.output.route.send(.presentBossAppBottomSheet(viewModel))
            }
            .store(in: &cancellables)
    }
    
    private func fetchCurrentLocation() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let currentLocation = try await dependency.locationManager.getCurrentLocation()
                state.cameraPosition = currentLocation
                output.cameraPosition.send(currentLocation)
                updateAddress(location: currentLocation)
            } catch {
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func checkStoreExistedAround(location: CLLocation) {
        Task {
            let input = FetchAroundStoreInput(
                distanceM: 50,
                targetStores: [.userStore, .bossStore],
                mapLatitude: location.coordinate.latitude,
                mapLongitude: location.coordinate.longitude
            )
            let result = await dependency.storeRepository.fetchAroundStores(input: input)
            
            switch result {
            case .success(let response):
                if response.contents.isEmpty {
                    pushWriteDetail(location: location)
                } else {
                    presentConfirmPopup(stores: response.contents, address: output.address.value)
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
                output.address.send(address)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
        
    private func presentConfirmPopup(stores: [StoreWithExtraResponse], address: String) {
        let config = AddressConfirmBottomSheetViewModel.Config(stores: stores, address: address)
        let viewModel = AddressConfirmBottomSheetViewModel(config: config)
        
        viewModel.output.didTapConfirm
            .subscribe(input.didTapConfirmAddress)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentConfirmPopup(viewModel))
    }
    
    private func pushWriteDetail(location: CLLocation) {
        // TODO: 가게 상세 구현하고 나서 연동 필요
//        guard let cameraPosition = state.cameraPosition else { return }
//        let cameraLocation = LocationResponse(
//            latitude: cameraPosition.coordinate.latitude,
//            longitude: cameraPosition.coordinate.longitude
//        )
//        let config = WriteDetailViewModel.WriteConfig(location: cameraLocation, address: state.address)
//        let viewModel = WriteDetailViewModel(config: config)
//        
//        output.route.send(.pushWriteDetail(viewModel))
    }
}


// MARK: Log
extension WriteAddressViewModel {
    private func sendClickCurrentLocationLog() {
        dependency.logManager.sendEvent(LogEvent(
            screen: output.screenName,
            eventName: .clickCurrentLocation,
            extraParameters: [.address: output.address.value]
        ))
    }
    
    private func sendClickSetAddressLog(address: String) {
        dependency.logManager.sendEvent(LogEvent(
            screen: output.screenName,
            eventName: .clickSetAddress,
            extraParameters: [.address: output.address.value]
        ))
    }
}
