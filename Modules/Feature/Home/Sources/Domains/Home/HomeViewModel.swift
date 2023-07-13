import Foundation
import Combine
import CoreLocation

import Networking
import Common

final class HomeViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Double, Never>()
        let changeMaxDistance = PassthroughSubject<Double, Never>()
        let changeMapLocation = PassthroughSubject<CLLocation, Never>()
        let selectCategory = PassthroughSubject<Category?, Never>()
        let onToggleSort = PassthroughSubject<StoreSortType, Never>()
        let searchByAddress = PassthroughSubject<CLLocation, Never>()
        let onTapResearch = PassthroughSubject<Void, Never>()
        let onTapCurrentLocation = PassthroughSubject<Void, Never>()
        let selectStore = PassthroughSubject<Int, Never>()
        let onTapStore = PassthroughSubject<Int, Never>()
        let onTapVisitButton = PassthroughSubject<Int, Never>()
        let onTapMarker = PassthroughSubject<Int, Never>()
        let onTapCurrentMarker = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let address = PassthroughSubject<String, Never>()
        let categoryFilter = PassthroughSubject<Category?, Never>()
        let isOnlyBossStore = PassthroughSubject<Bool, Never>()
        let isHiddenResearchButton = PassthroughSubject<Bool, Never>()
        let cameraPosition = PassthroughSubject<CLLocation, Never>()
        let advertisementMarker = PassthroughSubject<Advertisement, Never>()
        let storeCards = PassthroughSubject<[StoreCard], Never>()
        let scrollToIndex = PassthroughSubject<Int, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var address = ""
        var categoryFilter: Category?
        var sortType: StoreSortType = .distanceAsc
        var isOnlyBossStore = false
        var mapMaxDistance: Double?
        var newCameraPosition: CLLocation?
        var newMapMaxDistance: Double?
        var resultCameraPosition: CLLocation?
        var currentLocation: CLLocation?
        var advertisementMarker: Advertisement? // Splash에서 조회하여 Context로 전달 받아야 함
        var stores: [StoreCard] = []
        var selectedIndex = 0
    }
    
    enum Route {
        case presentCategoryFilter
        case presentListView
        case pushStoreDetail(storeId: String)
        case presentVisit // 파라미터 필요
        case presentPolicy
        case presentMarkerAdvertisement
        case showErrorAlert(Error)
    }
    
    let input = Input()
    let output = Output()
    private var state: State
    private let storeService: StoreServiceProtocol
    private let advertisementService: AdvertisementServiceProtocol
    private let userService: UserServiceProtocol
    private let locationManager: LocationManagerProtocol
    
    init(
        state: State = State(),
        storeService: StoreServiceProtocol = StoreService(),
        advertisementService: AdvertisementServiceProtocol = AdvertisementService(),
        userService: UserServiceProtocol = UserService(),
        locationManager: LocationManagerProtocol = LocationManager.shared
    ) {
        self.state = state
        self.storeService = storeService
        self.advertisementService = advertisementService
        self.userService = userService
        self.locationManager = locationManager
        super.init()
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, distance in
                owner.state.mapMaxDistance = distance
                owner.output.showLoading.send(true)
            })
            .flatMap { owner, _  in
                owner.locationManager.getCurrentLocationPublisher()
                    .catch { error -> AnyPublisher<CLLocation, Never> in
                        owner.output.route.send(.showErrorAlert(error))
                        return Empty().eraseToAnyPublisher()
                    }
            }
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, location in
                owner.state.resultCameraPosition = location
                owner.state.currentLocation = owner.state.resultCameraPosition
                owner.output.cameraPosition.send(location)
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, result in
                owner.output.showLoading.send(false)
                
                switch result {
                case .success(let storeCard):
                    owner.state.stores = storeCard
                    owner.output.storeCards.send(storeCard)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            })
            .store(in: &cancellables)
        
        input.changeMaxDistance
            .withUnretained(self)
            .sink { owner, distance in
                owner.state.newMapMaxDistance = distance
                owner.output.isHiddenResearchButton.send(false)
            }
            .store(in: &cancellables)
        
        input.changeMapLocation
            .withUnretained(self)
            .sink { owner, location in
                owner.state.newCameraPosition = location
                owner.output.isHiddenResearchButton.send(false)
            }
            .store(in: &cancellables)
        
        input.selectCategory
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, categoryFilter in
                owner.state.categoryFilter = categoryFilter
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, result in
                owner.output.showLoading.send(false)
                
                switch result {
                case .success(let storeCard):
                    owner.state.stores = storeCard
                    owner.output.storeCards.send(storeCard)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            })
            .store(in: &cancellables)
        
        input.onToggleSort
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, sortType in
                owner.state.sortType = sortType
            })
            .asyncMap { owner, _ in
                await owner.fetchAroundStore()
            }
            .withUnretained(self)
            .sink(receiveValue: { owner, result in
                owner.output.showLoading.send(false)
                
                switch result {
                case .success(let storeCard):
                    owner.state.stores = storeCard
                    owner.output.storeCards.send(storeCard)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            })
            .store(in: &cancellables)
        
        input.onTapCurrentLocation
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.locationManager.getCurrentLocationPublisher()
                    .catch { error -> AnyPublisher<CLLocation, Never> in
                        owner.output.route.send(.showErrorAlert(error))
                        return Empty().eraseToAnyPublisher()
                    }
            }
            .withUnretained(self)
            .sink { owner, location in
                owner.state.currentLocation = location
                owner.output.cameraPosition.send(location)
            }
            .store(in: &cancellables)
    }
    
    private func fetchAroundStore() async -> Result<[StoreCard], Error> {
        var categoryIds: [String]? = nil
        if let filterCategory = state.categoryFilter {
            categoryIds = [filterCategory.category]
        }
        let targetStores: [StoreType] = state.isOnlyBossStore ? [.bossStore] : [.userStore, .bossStore]
        let input = FetchAroundStoreInput(
            distanceM: state.mapMaxDistance,
            categoryIds: categoryIds,
            targetStores: targetStores.map { $0.rawValue },
            sortType: state.sortType.rawValue,
            filterCertifiedStores: false,
            size: 10,
            cursor: nil,
            mapLatitude: state.resultCameraPosition?.coordinate.latitude ?? 0,
            mapLongitude: state.resultCameraPosition?.coordinate.longitude ?? 0
        )
        
        return await storeService.fetchAroundStores(
            input: input,
            latitude: state.currentLocation?.coordinate.latitude ?? 0,
            longitude: state.currentLocation?.coordinate.longitude ?? 0
        )
        .map{ response in
            response.contents.map(StoreCard.init(response:))
        }
    }
}
