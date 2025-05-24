import Foundation
import Combine
import CoreLocation

import Networking
import Model
import Common
import Log
import AppInterface
import MembershipInterface
import Feed
import FeedInterface

extension HomeViewModel {
    enum Constant {
        static let defaultLocation = CLLocation(latitude: 37.497941, longitude: 127.027616) // 강남역
    }
    
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let onLoadFilter = PassthroughSubject<Void, Never>()
        let onMapLoad = PassthroughSubject<Double, Never>()
        let changeMaxDistance = PassthroughSubject<Double, Never>()
        let changeMapLocation = PassthroughSubject<CLLocation, Never>()
        let onTapCategoryFilter = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<StoreFoodCategoryResponse?, Never>()
        let onTapOnlyRecentActivity = PassthroughSubject<Void, Never>()
        let onToggleSort = PassthroughSubject<StoreSortType, Never>()
        let onTapOnlyBoss = PassthroughSubject<Void, Never>()
        let onTapSearchAddress = PassthroughSubject<Void, Never>()
        let searchByAddress = PassthroughSubject<PlaceDocument, Never>()
        let onTapResearch = PassthroughSubject<Void, Never>()
        let onTapCurrentLocation = PassthroughSubject<Void, Never>()
        let onTapListView = PassthroughSubject<Void, Never>()
        let selectStore = PassthroughSubject<Int, Never>()
        let onTapStore = PassthroughSubject<Int, Never>()
        let onTapMarker = PassthroughSubject<Int, Never>()
        let onTapCurrentMarker = PassthroughSubject<Void, Never>()
        let didTapFeedButton = PassthroughSubject<Void, Never>()
        
        // From SubViewModel
        let didTapCardActionButton = PassthroughSubject<SDLink, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .home
        let address = PassthroughSubject<String, Never>()
        let filterDatasource = CurrentValueSubject<[HomeFilterCollectionView.CellType], Never>([
            .category(nil),
            .recentActivity(false),
            .sortingFilter(.distanceAsc),
            .onlyBoss(false)
        ])
        let isHiddenResearchButton = PassthroughSubject<Bool, Never>()
        let cameraPosition = PassthroughSubject<CLLocation, Never>()
        let advertisementMarker = PassthroughSubject<AdvertisementResponse, Never>()
        let datasource = PassthroughSubject<[HomeCardSectionItem], Never>()
        let scrollToIndex = PassthroughSubject<Int, Never>()
        let isShowFilterTooltip = PassthroughSubject<Bool, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var address = ""
        var categoryFilter: StoreFoodCategoryResponse?
        var homeCardComponents: [any HomeCardComponent] = []
        var sortType: StoreSortType = .distanceAsc
        var isOnlyBossStore = false
        var isOnlyRecentActivity = false
        var mapMaxDistance: Double?
        var newCameraPosition: CLLocation?
        var newMapMaxDistance: Double?
        var resultCameraPosition: CLLocation?
        var currentLocation: CLLocation?
        var advertisementMarker: AdvertisementResponse?
        var selectedIndex = 0
        var hasMore: Bool = true
        var nextCursor: String? = nil
        var user: UserDetailResponse?
    }
    
    enum Route {
        case presentCategoryFilter(CategoryFilterViewModel)
        case presentListView(HomeListViewModel)
        case presentVisit(StoreResponse)
        case presentPolicy
        case presentMarkerAdvertisement
        case presentSearchAddress(SearchAddressViewModel)
        case showErrorAlert(Error)
        case deepLink(SDLink)
        case presentAccountInfo(BaseViewModel)
        case presentFeedList(FeedListViewModel)
    }
    
    struct Dependency {
        let homeRepository: HomeRepository
        let advertisementRepository: AdvertisementRepository
        let userRepository: UserRepository
        let mapRepository: MapRepository
        let locationManager: LocationManagerProtocol
        var preference: Preference
        let logManager: LogManagerProtocol
        let appModuleInterface: AppModuleInterface
        
        init(
            homeRepository: HomeRepository = HomeRepositoryImpl(),
            advertisementRepository: AdvertisementRepository = AdvertisementRepositoryImpl(),
            userRepository: UserRepository = UserRepositoryImpl(),
            mapRepository: MapRepository = MapRepositoryImpl(),
            locationManager: LocationManagerProtocol = LocationManager.shared,
            preference: Preference = .shared,
            logManager: LogManagerProtocol = LogManager.shared,
            appModuleInterface: AppModuleInterface = Environment.appModuleInterface
        ) {
            self.homeRepository = homeRepository
            self.advertisementRepository = advertisementRepository
            self.userRepository = userRepository
            self.mapRepository = mapRepository
            self.locationManager = locationManager
            self.preference = preference
            self.logManager = logManager
            self.appModuleInterface = appModuleInterface
        }
    }
}

final class HomeViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    
    var currentAddress: String {
        state.address
    }
    
    var focusedPosition: CLLocation? {
        state.newCameraPosition
    }
    
    private var state = State()
    private var dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        
        super.init()
    }
    
    override func bind() {
        input.onMapLoad
            .sink { [weak self] _ in
                self?.fetchAdvertisementMarker()
            }
            .store(in: &cancellables)
        
        let getCurrentLocation = input.onMapLoad
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, distance in
                owner.state.mapMaxDistance = distance
                owner.output.showLoading.send(true)
            })
            .flatMap { owner, _  in
                owner.dependency.locationManager.getCurrentLocationPublisher()
                    .catch { error -> AnyPublisher<CLLocation, Never> in
                        owner.output.showLoading.send(false)
                        owner.output.route.send(.showErrorAlert(error))
                        
                        return Just(Constant.defaultLocation).eraseToAnyPublisher()
                    }
            }
            .share()
        
        getCurrentLocation
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, location: CLLocation) in
                owner.dependency.preference.userCurrentLocation = location
                owner.fetchAddress(location: location)
            })
            .store(in: &cancellables)
        
        getCurrentLocation
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, location: CLLocation) in
                owner.state.resultCameraPosition = location
                owner.state.currentLocation = owner.state.resultCameraPosition
                owner.output.cameraPosition.send(location)
                owner.dependency.preference.userCurrentLocation = location
                owner.fetchHomeCards()
            })
            .store(in: &cancellables)
                
        input.viewDidLoad
            .sink(receiveValue: { [weak self] in
                self?.presentPolicyIfNeeded()
            })
            .store(in: &cancellables)
        
        input.changeMaxDistance
            .sink { [weak self] distance in
                self?.state.newMapMaxDistance = distance
                self?.output.isHiddenResearchButton.send(false)
            }
            .store(in: &cancellables)
        
        input.changeMapLocation
            .sink { [weak self] location in
                self?.state.newCameraPosition = location
                self?.output.isHiddenResearchButton.send(false)
            }
            .store(in: &cancellables)
        
        input.onTapCategoryFilter
            .sink(receiveValue: { [weak self] _ in
                self?.hiddenTooltip()
                self?.sendClickCategoryFilterLog()
                self?.presentCategoryFilter()
            })
            .store(in: &cancellables)
        
        input.selectCategory
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, category: StoreFoodCategoryResponse?) in
                owner.state.categoryFilter = category
                owner.fetchHomeCards()
                owner.hiddenTooltip()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)
        
        input.onTapOnlyRecentActivity
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, _) in
                owner.hiddenTooltip()
                owner.state.isOnlyRecentActivity.toggle()
                owner.sendClickRecentActivityFilter(value: owner.state.isOnlyRecentActivity)
                owner.fetchHomeCards()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)
        
        input.onToggleSort
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, sortType: StoreSortType) in
                owner.hiddenTooltip()
                owner.state.sortType = owner.state.sortType.toggled()
                owner.sendClickSortingFilterLog(sortType: sortType)
                owner.fetchHomeCards()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)
        
        input.onTapOnlyBoss
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, _) in
                owner.hiddenTooltip()
                owner.state.isOnlyBossStore.toggle()
                owner.sendClickOnlyBossFilterLog(isOn: owner.state.isOnlyBossStore)
                owner.fetchHomeCards()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)
        
        input.onTapSearchAddress
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                owner.sendClickAddressLog()
                owner.presentSearchAddress()
            }
            .store(in: &cancellables)
        
        input.searchByAddress
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, placeDocument: PlaceDocument) in
                owner.state.address = placeDocument.placeName
                owner.output.address.send(placeDocument.placeName)
                
                let latitude = Double(placeDocument.y) ?? 0
                let longitude = Double(placeDocument.x) ?? 0
                let location = CLLocation(latitude: latitude, longitude: longitude)
                owner.state.newCameraPosition = location
                owner.state.resultCameraPosition = location
                owner.output.cameraPosition.send(location)
                owner.fetchHomeCards()
                owner.output.isHiddenResearchButton.send(true)
            })
            .store(in: &cancellables)
        
        input.onTapResearch
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, _) in
                owner.output.showLoading.send(true)
                owner.state.mapMaxDistance = owner.state.newMapMaxDistance
                owner.state.resultCameraPosition = owner.state.newCameraPosition
                owner.fetchHomeCards()
                owner.output.isHiddenResearchButton.send(true)
            })
            .store(in: &cancellables)
        
        input.onTapResearch
            .withUnretained(self)
            .asyncMap { owner, _ in
                let latitude = owner.state.newCameraPosition?.coordinate.latitude ?? Constant.defaultLocation.coordinate.latitude
                let longitude = owner.state.newCameraPosition?.coordinate.longitude ?? Constant.defaultLocation.coordinate.longitude
                
                return await owner.dependency.mapRepository.getAddressFromLocation(
                    latitude: latitude,
                    longitude: longitude
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let address):
                    owner.state.address = address
                    owner.output.address.send(address)
                    
                case .failure(let error):
                    owner.output.route.send(.showErrorAlert(error))
                }
            }
            .store(in: &cancellables)
            
        
        input.onTapCurrentLocation
            .withUnretained(self)
            .flatMap { owner, _ in
                owner.dependency.locationManager.getCurrentLocationPublisher()
                    .catch { error -> AnyPublisher<CLLocation, Never> in
                        owner.output.route.send(.showErrorAlert(error))
                        return Empty().eraseToAnyPublisher()
                    }
            }
            .withUnretained(self)
            .sink { owner, location in
                owner.sendClickCurrentLocationLog()
                owner.dependency.preference.userCurrentLocation = location
                owner.state.currentLocation = location
                owner.output.cameraPosition.send(location)
            }
            .store(in: &cancellables)
        
        input.onTapListView
            .sink(receiveValue: { [weak self] _ in
                self?.presentListView()
            })
            .store(in: &cancellables)
        
        input.selectStore
            .withLatestFrom(output.datasource) { ($0, $1) }
            .handleEvents(receiveOutput: { [weak self] (index: Int, items: [HomeCardSectionItem]) in
                self?.output.scrollToIndex.send(index)
                self?.state.selectedIndex = index
            })
            .compactMap { (index: Int, items: [HomeCardSectionItem]) in
                return items[safe: index]
            }
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, sectionItem: HomeCardSectionItem) in
                if case .store(let cellViewModel) = sectionItem,
                   let location = cellViewModel.output.data.marker?.location {
                    let cameraPosition = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    owner.output.cameraPosition.send(cameraPosition)
                }
            })
            .store(in: &cancellables)
        
        input.onTapMarker
            .withLatestFrom(output.datasource) { ($0, $1) }
            .sink(receiveValue: { [weak self] (index: Int, items: [HomeCardSectionItem]) in
                guard let self,
                      let item = items[safe: index],
                      case .store(let cellViewModel) = item,
                      let marker = cellViewModel.output.data.marker else { return }
                let cameraPosition = CLLocation(
                    latitude: marker.location.latitude,
                    longitude: marker.location.longitude
                )
                output.cameraPosition.send(cameraPosition)
                output.scrollToIndex.send(index)
            })
            .store(in: &cancellables)
        
        input.onTapStore
            .withLatestFrom(output.datasource) { ($0, $1) }
            .sink(receiveValue: { [weak self] (index: Int, items: [HomeCardSectionItem]) in
                guard let self,
                      let item = items[safe: index] else { return }
                
                if index == state.selectedIndex {
                    routeCard(item)
                } else {
                    selectCard(item, index: index)
                }
            })
            .store(in: &cancellables)
        
        input.onTapCurrentMarker
            .filter { [weak self] in
                return self?.state.advertisementMarker != nil
            }
            .map { Route.presentMarkerAdvertisement }
            .handleEvents(receiveOutput: { [weak self] _ in
                guard let self = self,
                      let advertisement = state.advertisementMarker else { return }
                sendClickAdMarker(advertisement: advertisement)
            })
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.onLoadFilter
            .sink { [weak self] _ in
                self?.showFilterTooltipIfNeeded()
            }
            .store(in: &cancellables)
        
        input.didTapFeedButton
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                let mapLocation = owner.state.newCameraPosition ?? owner.state.currentLocation 
                let config = FeedListViewModelConfig(
                    mapLatitude: mapLocation?.coordinate.latitude,
                    mapLongitude: mapLocation?.coordinate.longitude
                )
                let viewModel = FeedListViewModel(config: config)
                owner.output.route.send(.presentFeedList(viewModel))
            }
            .store(in: &cancellables)
    }
    
    private func updateFilterDatasource() {
        let datasource: [HomeFilterCollectionView.CellType] = [
            .category(state.categoryFilter),
            .recentActivity(state.isOnlyRecentActivity),
            .sortingFilter(state.sortType),
            .onlyBoss(state.isOnlyBossStore)
        ]
        
        output.filterDatasource.send(datasource)
    }
    
    private func updateDatasource() {
        var datasource: [HomeCardSectionItem] = []
        for component in state.homeCardComponents {
            if let data = component as? HomeCardSectionResponse {
                let config = HomeStoreCardCellViewModel.Config(data: data)
                let viewModel = HomeStoreCardCellViewModel(config: config)
                bindHomeStoreCellViewModel(viewModel)
                datasource.append(.store(viewModel))
            } else if let data = component as? HomeAdCardSectionResponse {
                datasource.append(.advertisement(data))
            } else if let data = component as? HomeAdmobCardSectionResponse {
                datasource.append(.admob(data))
            }
        }
        
        if datasource.isEmpty {
            datasource = [.empty]
        }
        
        output.datasource.send(datasource)
        output.scrollToIndex.send(0)
    }
    
    private func fetchHomeCards() {
        Task {
            output.showLoading.send(true)
            let input = createFetchHomeCardInput()
            let result = await dependency.homeRepository.fetchHomeCards(input: input)
            
            switch result {
            case .success(let response):
                state.nextCursor = response.cursor?.nextCursor
                state.hasMore = response.cursor?.hasMore ?? false
                state.homeCardComponents = response.contents
                updateDatasource()
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
            output.showLoading.send(false)
        }
        .store(in: taskBag)
    }
    
    private func createFetchHomeCardInput() -> FetchHomeCardInput {
        var categoryIds: [String]? = nil
        if let filterCategory = state.categoryFilter {
            categoryIds = [filterCategory.categoryId]
        }
        let targetStores: [StoreType] = state.isOnlyBossStore ? [.bossStore] : [.userStore, .bossStore]
        let filterConditions: [ActivitiesStatus] = state.isOnlyRecentActivity ? [.recentActivity] : [.recentActivity, .noRecentActivity]
        return FetchHomeCardInput(
            distanceM: state.mapMaxDistance ?? 0,
            categoryIds: categoryIds,
            targetStores: targetStores,
            sortType: state.sortType,
            filterCertifiedStores: false,
            filterConditions: filterConditions,
            size: 10,
            cursor: nil,
            mapLatitude: state.resultCameraPosition?.coordinate.latitude ?? 0,
            mapLongitude: state.resultCameraPosition?.coordinate.longitude ?? 0
        )
    }
    
    private func fetchAdvertisementMarker() {
        Task {
            let input = FetchAdvertisementInput(position: .storeMarker, size: nil)
            let response = await dependency.advertisementRepository.fetchAdvertisements(input: input).data
            
            guard let advertisement = response?.advertisements.first else { return }
            state.advertisementMarker = advertisement
            output.advertisementMarker.send(advertisement)
        }
        .store(in: taskBag)
    }
    
    private func presentSearchAddress() {
        let viewModel = SearchAddressViewModel()
        viewModel.output.selectAddress
            .subscribe(input.searchByAddress)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentSearchAddress(viewModel))
    }
    
    private func bindHomeListViewModel(_ viewModel: HomeListViewModel) {
        viewModel.output.onToggleSort
            .subscribe(input.onToggleSort)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.onTapOnlyBoss
            .subscribe(input.onTapOnlyBoss)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.onSelectCategoryFilter
            .subscribe(input.selectCategory)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.onTapOnlyRecentActivity
            .subscribe(input.onTapOnlyRecentActivity)
            .store(in: &viewModel.cancellables)
    }
    
    private func hiddenTooltip() {
        guard dependency.preference.isShownFilterTooltip.isNot else { return }
        dependency.preference.isShownFilterTooltip = true
        output.isShowFilterTooltip.send(false)
    }
    
    private func fetchAddress(location: CLLocation) {
        Task {
            let result = await dependency.mapRepository.getAddressFromLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            switch result {
            case .success(let address):
                state.address = address
                output.address.send(address)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func presentCategoryFilter() {
        let config = CategoryFilterViewModel.Config(currentCategory: state.categoryFilter)
        let viewModel = CategoryFilterViewModel(config: config)
        
        viewModel.output.didSelectCategory
            .subscribe(input.selectCategory)
            .store(in: &viewModel.cancellables)
        output.route.send(.presentCategoryFilter(viewModel))
    }
    
    private func presentPolicyIfNeeded() {
        Task {
            let user = await dependency.userRepository.fetchUser().data
            
            guard
                let user,
                MarketingConsent(value: user.settings.marketingConsent) == .unverified
            else {
                return
            }
            
            output.route.send(.presentPolicy)
        }.store(in: taskBag)
    }
    
    private func showFilterTooltipIfNeeded() {
        guard dependency.preference.isShownFilterTooltip.isNot else { return }
        output.isShowFilterTooltip.send(true)
    }
    
    private func selectCard(_ item: HomeCardSectionItem, index: Int) {
        if case .store(let cellViewModel) = item,
           let location = cellViewModel.output.data.marker?.location {
            let cameraPosition = CLLocation(latitude: location.latitude, longitude: location.longitude)
            output.cameraPosition.send(cameraPosition)
        }
        
        output.scrollToIndex.send(index)
        state.selectedIndex = index
    }
    
    private func routeCard(_ item: HomeCardSectionItem) {
        switch item {
        case .store(let cellViewModel):
            if let link = cellViewModel.output.data.link {
                output.route.send(.deepLink(link))
            }
        case .advertisement(let data):
//            sendClickAdCard // TODO: 서버에서 advertisement_id 내려오면 추가 필요
            if let link = data.link {
                output.route.send(.deepLink(link))
            }
        default:
            break
        }
    }
    
    private func didTapCardButton(_ component: any HomeCardComponent) {
        guard let component = component as? HomeAdCardSectionResponse,
              let link = component.link else { return }
        
        output.route.send(.deepLink(link))
    }
    
    private func presentListView() {
        let config = HomeListViewModel.Config(
            categoryFilter: state.categoryFilter,
            isOnlyRecentActivity: state.isOnlyRecentActivity,
            sortType: state.sortType,
            isOnlyBossStore: state.isOnlyBossStore,
            mapLocation: state.resultCameraPosition,
            mapMaxDistance: state.mapMaxDistance
        )
        let viewModel = HomeListViewModel(config: config)
        bindHomeListViewModel(viewModel)
        output.route.send(.presentListView(viewModel))
    }
}

// MARK: Subcell
extension HomeViewModel {
    private func bindHomeStoreCellViewModel(_ viewModel: HomeStoreCardCellViewModel) {
        viewModel.output.didTapActionButton
            .subscribe(input.didTapCardActionButton)
            .store(in: &viewModel.cancellables)
    }
}

// MARK: Log
extension HomeViewModel {
    private func sendClickCurrentLocationLog() {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickCurrentLocation
        ))
    }
    
    private func sendClickAddressLog() {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickAddressField
        ))
    }
    
    private func sendClickCategoryFilterLog() {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickCategoryFilter
        ))
    }
    
    private func sendClickOnlyBossFilterLog(isOn: Bool) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickBossFilter,
            extraParameters: [.value: isOn]
        ))
    }
    
    private func sendClickSortingFilterLog(sortType: StoreSortType) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickSorting,
            extraParameters: [.type: sortType.rawValue]
        ))
    }
    
    private func sendClickAdCard(advertisement: AdvertisementResponse) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickAdCard,
            extraParameters: [.advertisementId: "\(advertisement.advertisementId)"]
        ))
    }
    
    private func sendClickAdMarker(advertisement: AdvertisementResponse) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickAdMarker,
            extraParameters: [.advertisementId: "\(advertisement.advertisementId)"]
        ))
    }
    
    private func sendClickRecentActivityFilter(value: Bool) {
        dependency.logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickRecentActivityFilter,
            extraParameters: [.value: value]
        ))
    }
}

extension HomeViewModel: HomeFilterSelectable {
    var onTapCategoryFilter: PassthroughSubject<Void, Never> {
        input.onTapCategoryFilter
    }
    
    var onTapOnlyRecentActivity: PassthroughSubject<Void, Never> {
        input.onTapOnlyRecentActivity
    }
    
    var onToggleSort: PassthroughSubject<Model.StoreSortType, Never> {
        input.onToggleSort
    }
    
    var onTapOnlyBoss: PassthroughSubject<Void, Never> {
        input.onTapOnlyBoss
    }
    
    var selectCategory: PassthroughSubject<StoreFoodCategoryResponse?, Never> {
        input.selectCategory
    }
    
    var filterDatasource: CurrentValueSubject<[HomeFilterCollectionView.CellType], Never> {
        output.filterDatasource
    }
}
