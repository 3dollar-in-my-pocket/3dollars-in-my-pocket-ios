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
        static let pageSize = 10
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
        let onTapRadioOption = PassthroughSubject<(paramKey: String, optionIndex: Int), Never>()
        let onTapActionLink = PassthroughSubject<SDLink, Never>()
        let onTapCloseSelectedCategory = PassthroughSubject<Void, Never>()
        let onTapSearchAddress = PassthroughSubject<Void, Never>()
        let searchByAddress = PassthroughSubject<PlaceDocument, Never>()
        let onTapResearch = PassthroughSubject<Void, Never>()
        let onTapCurrentLocation = PassthroughSubject<Void, Never>()
        let onTapListView = PassthroughSubject<Void, Never>()
        let onTapMarker = PassthroughSubject<Int, Never>()
        let onTapCurrentMarker = PassthroughSubject<Void, Never>()
        let didTapFeedButton = PassthroughSubject<Void, Never>()

        // From bottom sheet
        let bottomSheetWillLoadMore = PassthroughSubject<Void, Never>()
        let bottomSheetDidTapCard = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let screenName: ScreenName = .home
        let address = PassthroughSubject<String, Never>()
        let filterDatasource = CurrentValueSubject<[HomeFilterCollectionView.CellType], Never>([])
        let isHiddenResearchButton = PassthroughSubject<Bool, Never>()
        let cameraPosition = PassthroughSubject<CLLocation, Never>()
        let advertisementMarker = PassthroughSubject<AdvertisementResponse, Never>()
        /// 바텀시트로 전달할 카드 목록.
        let bottomSheetCards = CurrentValueSubject<[any HomeListCardComponent], Never>([])
        /// 지도 마커로 그릴 카드(BasicCard 만 포함). 인덱스는 cards 와 일치하지 않을 수 있다.
        let markerCards = CurrentValueSubject<[HomeListBasicCardResponse], Never>([])
        /// 마커 탭 시 바텀시트가 해당 카드로 스크롤하도록 알려준다.
        let scrollBottomSheetToIndex = PassthroughSubject<Int, Never>()
        let isShowFilterTooltip = PassthroughSubject<Bool, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    struct State {
        var address = ""
        var categoryFilter: StoreFoodCategoryResponse?
        var cards: [any HomeListCardComponent] = []
        var sortType: StoreSortType = .distanceAsc
        var isOnlyBossStore = false
        var isOnlyRecentActivity = true
        var openStatuses: [FilterOpenStatuses]?
        var filterSections: [any HomeScreenSection] = []
        var radioSelection: [String: Int] = [:]
        var hasLoadedFilterScreen = false
        var mapMaxDistance: Double?
        var newCameraPosition: CLLocation?
        var newMapMaxDistance: Double?
        var resultCameraPosition: CLLocation?
        var currentLocation: CLLocation?
        var advertisementMarker: AdvertisementResponse?
        var hasMore: Bool = false
        var nextCursor: String?
        var isLoading: Bool = false
        var user: UserDetailResponse?
    }

    enum Route {
        case presentCategoryFilter(CategoryFilterViewModel)
        case presentVisit(StoreResponse)
        case presentPolicy
        case presentMarkerAdvertisement
        case presentStorePreview(storeId: Int, latitude: Double, longitude: Double)
        case dismissStorePreview
        case presentSearchAddress(SearchAddressViewModel)
        case showErrorAlert(Error)
        case deepLink(SDLink)
        case presentAccountInfo(BaseViewModel)
        case presentFeedList(FeedListViewModel)
    }

    struct Dependency {
        let screenRepository: ScreenRepository
        let advertisementRepository: AdvertisementRepository
        let userRepository: UserRepository
        let mapRepository: MapRepository
        let locationManager: LocationManagerProtocol
        var preference: Preference
        let logManager: LogManagerProtocol
        let appModuleInterface: AppModuleInterface

        init(
            screenRepository: ScreenRepository = ScreenRepositoryImpl(),
            advertisementRepository: AdvertisementRepository = AdvertisementRepositoryImpl(),
            userRepository: UserRepository = UserRepositoryImpl(),
            mapRepository: MapRepository = MapRepositoryImpl(),
            locationManager: LocationManagerProtocol = LocationManager.shared,
            preference: Preference = .shared,
            logManager: LogManagerProtocol = LogManager.shared,
            appModuleInterface: AppModuleInterface = Environment.appModuleInterface
        ) {
            self.screenRepository = screenRepository
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
    /// 필터 응답이 도착하기 전에 첫 카드 요청이 발사되면 dynamicParams 가 비어버리므로,
    /// 첫 fetch 호출만 위치 + 필터 응답 두 신호가 모두 준비될 때까지 게이팅한다.
    private let filterScreenLoaded = PassthroughSubject<Void, Never>()

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
                owner.state.newCameraPosition = location
                owner.output.cameraPosition.send(location)
                owner.dependency.preference.userCurrentLocation = location
            })
            .store(in: &cancellables)

        // 첫 카드 요청은 위치 + 필터 응답이 모두 준비된 뒤에만 발사한다.
        Publishers.CombineLatest(getCurrentLocation, filterScreenLoaded)
            .first()
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, _) in
                owner.fetchInitialCards()
            })
            .store(in: &cancellables)

        input.viewDidLoad
            .sink(receiveValue: { [weak self] in
                self?.presentPolicyIfNeeded()
                self?.fetchFilterScreen()
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
                owner.fetchInitialCards()
                owner.hiddenTooltip()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)

        input.onTapOnlyRecentActivity
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, _) in
                owner.hiddenTooltip()
                owner.state.isOnlyRecentActivity.toggle()
                owner.sendClickRecentActivityFilter(isOn: owner.state.isOnlyRecentActivity)
                owner.syncRadioSelectionFromLegacy()
                owner.fetchInitialCards()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)

        input.onToggleSort
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, sortType: StoreSortType) in
                owner.hiddenTooltip()
                owner.state.sortType = owner.state.sortType.toggled()
                owner.sendClickSortingFilterLog(sortType: sortType)
                owner.syncRadioSelectionFromLegacy()
                owner.fetchInitialCards()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)

        input.onTapOnlyBoss
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, _) in
                owner.hiddenTooltip()
                owner.state.isOnlyBossStore.toggle()
                owner.sendClickOnlyBossFilterLog(isOn: owner.state.isOnlyBossStore)
                owner.syncRadioSelectionFromLegacy()
                owner.fetchInitialCards()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)

        input.onTapRadioOption
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, payload: (paramKey: String, optionIndex: Int)) in
                owner.hiddenTooltip()
                owner.applyRadioSelection(paramKey: payload.paramKey, optionIndex: payload.optionIndex)
                owner.fetchInitialCards()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)

        input.onTapActionLink
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, link: SDLink) in
                owner.sendActionBarClickLog(for: link)
                owner.output.route.send(.deepLink(link))
            })
            .store(in: &cancellables)

        input.onTapCloseSelectedCategory
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, _) in
                owner.sendCurrentCategoryCloseLog()
                owner.input.selectCategory.send(nil)
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
                owner.fetchInitialCards()
                owner.output.isHiddenResearchButton.send(true)
            })
            .store(in: &cancellables)

        input.onTapResearch
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, _) in
                owner.output.showLoading.send(true)
                owner.state.mapMaxDistance = owner.state.newMapMaxDistance
                owner.state.resultCameraPosition = owner.state.newCameraPosition
                owner.fetchInitialCards()
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

        input.onTapMarker
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeViewModel, index: Int) in
                owner.handleMarkerTap(at: index)
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
                owner.sendClickFeedButtonLog()
                owner.output.route.send(.presentFeedList(viewModel))
            }
            .store(in: &cancellables)

        input.bottomSheetWillLoadMore
            .withUnretained(self)
            .sink { (owner: HomeViewModel, _) in
                owner.fetchMoreCards()
            }
            .store(in: &cancellables)

        input.bottomSheetDidTapCard
            .withUnretained(self)
            .sink { (owner: HomeViewModel, index: Int) in
                owner.handleBottomSheetCardTap(at: index)
            }
            .store(in: &cancellables)
    }

    private var state_markerCards: [HomeListBasicCardResponse] {
        return state.cards.compactMap { $0 as? HomeListBasicCardResponse }.filter { $0.marker != nil }
    }

    private func fetchInitialCards() {
        Task { [weak self] in
            guard let self else { return }
            output.showLoading.send(true)
            state.isLoading = true
            state.nextCursor = nil
            state.hasMore = false

            let request = createFetchInput(cursor: nil)
            let result = await dependency.screenRepository.fetchHomeSectionList(input: request)

            state.isLoading = false
            output.showLoading.send(false)

            switch result {
            case .success(let response):
                state.cards = response.cards
                state.nextCursor = response.cursor?.nextCursor
                state.hasMore = response.cursor?.hasMore ?? false
                emitCards()
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
        .store(in: taskBag)
    }

    private func fetchMoreCards() {
        guard !state.isLoading, state.hasMore else { return }
        Task { [weak self] in
            guard let self else { return }
            state.isLoading = true

            let request = createFetchInput(cursor: state.nextCursor)
            let result = await dependency.screenRepository.fetchHomeSectionList(input: request)

            state.isLoading = false

            switch result {
            case .success(let response):
                state.cards.append(contentsOf: response.cards)
                state.nextCursor = response.cursor?.nextCursor
                state.hasMore = response.cursor?.hasMore ?? false
                emitCards()
            case .failure:
                // 페이지네이션 실패는 silent — 사용자 흐름을 끊지 않는다.
                break
            }
        }
        .store(in: taskBag)
    }

    private func emitCards() {
        output.bottomSheetCards.send(state.cards)
        output.markerCards.send(state_markerCards)
    }

    private func handleMarkerTap(at index: Int) {
        let cards = state_markerCards
        guard let card = cards[safe: index], let marker = card.marker else { return }
        guard let storeId = extractStoreId(from: card) else { return }

        sendClickMarkerLog()
        dependency.logManager.sendEvent(event: ClickEvent(clickLog: marker.clickLog))

        output.route.send(.presentStorePreview(
            storeId: storeId,
            latitude: marker.location.latitude,
            longitude: marker.location.longitude
        ))
    }

    private func extractStoreId(from card: HomeListBasicCardResponse) -> Int? {
        if let value = card.clickLog.extraParameters["storeId"]?.anyValue {
            if let int = value as? Int { return int }
            if let str = value as? String, let parsed = Int(str) { return parsed }
        }
        if let link = card.link?.link ?? card.marker?.link?.link {
            if let queryItems = URLComponents(string: "x://x/\(link)")?.queryItems,
               let storeIdString = queryItems.first(where: { $0.name == "storeId" })?.value,
               let storeId = Int(storeIdString) {
                return storeId
            }
        }
        return nil
    }

    private func handleBottomSheetCardTap(at index: Int) {
        guard let card = state.cards[safe: index] else { return }

        if let basic = card as? HomeListBasicCardResponse {
            sendClickHomeCardLog()
            dependency.logManager.sendEvent(event: ClickEvent(clickLog: basic.clickLog))
            if let link = basic.link {
                output.route.send(.deepLink(link))
            }
            // 카드 탭 시 카메라를 마커 위치로 이동
            if let marker = basic.marker {
                let cameraPosition = CLLocation(
                    latitude: marker.location.latitude,
                    longitude: marker.location.longitude
                )
                output.cameraPosition.send(cameraPosition)
            }
        } else if let admob = card as? HomeListAdmobCardResponse {
            dependency.logManager.sendEvent(event: ClickEvent(clickLog: admob.clickLog))
        } else if let empty = card as? HomeListEmptyCardResponse, let log = empty.clickLog {
            dependency.logManager.sendEvent(event: ClickEvent(clickLog: log))
        }
    }

    private func createFetchInput(cursor: String?) -> FetchHomeSectionListInput {
        var dynamicParams = collectDynamicParams()

        // 카테고리 필터는 SDU 응답과 별개로 사용자가 직접 선택하므로 dynamicParams 에 합성한다.
        if let category = state.categoryFilter {
            dynamicParams["categoryIds"] = category.categoryId
        }

        return FetchHomeSectionListInput(
            distanceM: state.mapMaxDistance,
            cursor: cursor,
            mapLatitude: state.resultCameraPosition?.coordinate.latitude ?? 0,
            mapLongitude: state.resultCameraPosition?.coordinate.longitude ?? 0,
            dynamicParams: dynamicParams
        )
    }

    private func collectDynamicParams() -> [String: String] {
        var params: [String: String] = [:]
        for case let radioBar as HomeFilterRadioBar in allBars {
            let selectedIndex = state.radioSelection[radioBar.paramKey] ?? 0
            guard let option = radioBar.options[safe: selectedIndex],
                  let paramValue = option.paramValue else { continue }
            params[radioBar.paramKey] = paramValue
        }
        // sortType 은 서버 required 필드. SDU 응답이 비었거나 sortType 라디오바가 없는 경우 기본값으로 보강.
        if params["sortType"] == nil {
            params["sortType"] = state.sortType.rawValue
        }
        return params
    }

    private func currentParamValue(for paramKey: String) -> String? {
        guard
            let radioBar = (allBars.first { ($0 as? HomeFilterRadioBar)?.paramKey == paramKey }) as? HomeFilterRadioBar,
            let idx = state.radioSelection[paramKey],
            let option = radioBar.options[safe: idx]
        else {
            return legacyParamValue(for: paramKey)
        }
        return option.paramValue
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
        .store(in: taskBag)
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

}

// MARK: SDUI Filter
extension HomeViewModel {
    private func updateFilterDatasource() {
        let datasource = state.hasLoadedFilterScreen
            ? flattenFilterDatasource()
            : makeFallbackFilterDatasource()
        output.filterDatasource.send(datasource)
    }

    private func fetchFilterScreen() {
        Task { @MainActor in
            let result = await dependency.screenRepository.fetchHomeFilterScreen()
            switch result {
            case .success(let response):
                state.filterSections = response.sections
                state.hasLoadedFilterScreen = true
                initializeRadioSelectionDefaults()
                syncRadioSelectionFromLegacy()
                output.filterDatasource.send(flattenFilterDatasource())
            case .failure:
                output.filterDatasource.send(makeFallbackFilterDatasource())
            }
            // 성공/실패와 무관하게 게이팅을 풀어 첫 fetch 가 진행되도록 한다.
            filterScreenLoaded.send()
        }
        .store(in: taskBag)
    }

    private var allBars: [any HomeFilterBar] {
        state.filterSections
            .compactMap { $0 as? HomeFilterSection }
            .flatMap(\.bars)
    }

    private func initializeRadioSelectionDefaults() {
        for case let radioBar as HomeFilterRadioBar in allBars where state.radioSelection[radioBar.paramKey] == nil {
            state.radioSelection[radioBar.paramKey] = 0
            if let firstOption = radioBar.options.first {
                applyParamValueToLegacyState(paramKey: radioBar.paramKey, paramValue: firstOption.paramValue)
            }
        }
    }

    private func applyRadioSelection(paramKey: String, optionIndex: Int) {
        guard let radioBar = (allBars.first { ($0 as? HomeFilterRadioBar)?.paramKey == paramKey }) as? HomeFilterRadioBar,
              let option = radioBar.options[safe: optionIndex] else { return }
        state.radioSelection[paramKey] = optionIndex
        applyParamValueToLegacyState(paramKey: paramKey, paramValue: option.paramValue)
        sendClickFilterLog(option: option)
    }

    private func sendClickFilterLog(option: HomeFilterRadioOption) {
        guard let clickLog = option.clickLog else { return }
        dependency.logManager.sendEvent(event: ClickEvent(clickLog: clickLog))
    }

    private func sendActionBarClickLog(for link: SDLink) {
        let actionBar = allBars
            .compactMap { $0 as? HomeFilterActionBar }
            .first { $0.button.link == link }
        guard let clickLog = actionBar?.clickLog else { return }
        dependency.logManager.sendEvent(event: ClickEvent(clickLog: clickLog))
    }

    private func sendCurrentCategoryCloseLog() {
        let currentCategory = allBars
            .compactMap { $0 as? HomeFilterCategoryBar }
            .first?
            .currentCategoryFilter
        guard let clickLog = currentCategory?.clickLog else { return }
        dependency.logManager.sendEvent(event: ClickEvent(clickLog: clickLog))
    }

    private func applyParamValueToLegacyState(paramKey: String, paramValue: String?) {
        switch paramKey {
        case "filterOpenStatuses":
            if let value = paramValue, let status = FilterOpenStatuses(rawValue: value) {
                state.openStatuses = [status]
            } else {
                state.openStatuses = nil
            }
        case "filterConditions":
            state.isOnlyRecentActivity = (paramValue != nil)
        case "sortType":
            state.sortType = paramValue.flatMap(StoreSortType.init(rawValue:)) ?? .distanceAsc
        case "targetStores":
            state.isOnlyBossStore = (paramValue == "BOSS_STORE")
        default:
            break
        }
    }

    private func syncRadioSelectionFromLegacy() {
        for case let radioBar as HomeFilterRadioBar in allBars {
            let targetValue: String? = legacyParamValue(for: radioBar.paramKey)
            if let idx = radioBar.options.firstIndex(where: { $0.paramValue == targetValue }) {
                state.radioSelection[radioBar.paramKey] = idx
            }
        }
    }

    private func legacyParamValue(for paramKey: String) -> String? {
        switch paramKey {
        case "filterOpenStatuses":
            return state.openStatuses?.first?.rawValue
        case "filterConditions":
            return state.isOnlyRecentActivity ? "RECENT_ACTIVITY" : nil
        case "sortType":
            return state.sortType.rawValue
        case "targetStores":
            return state.isOnlyBossStore ? "BOSS_STORE" : nil
        default:
            return nil
        }
    }

    private func flattenFilterDatasource() -> [HomeFilterCollectionView.CellType] {
        var cells: [HomeFilterCollectionView.CellType] = []
        for bar in allBars {
            switch bar {
            case let categoryBar as HomeFilterCategoryBar:
                cells.append(.chip(categoryBar.categoriesFilter, action: .openCategoryFilter))
                if let category = state.categoryFilter {
                    let fontColor = categoryBar.currentCategoryFilter?.fontColor ?? "#000000"
                    let chip = makeSelectedCategoryChip(category: category, fontColor: fontColor)
                    cells.append(.selectedCategoryChip(chip, current: categoryBar.currentCategoryFilter))
                }
            case let radioBar as HomeFilterRadioBar:
                let selectedIndex = state.radioSelection[radioBar.paramKey] ?? 0
                guard radioBar.options.isEmpty.isNot,
                      let currentOption = radioBar.options[safe: selectedIndex] else { break }
                let nextIndex = (selectedIndex + 1) % radioBar.options.count
                let action = HomeFilterCollectionView.ChipAction.selectRadio(paramKey: radioBar.paramKey, optionIndex: nextIndex)
                cells.append(.chip(currentOption.chip, action: action))
            case let actionBar as HomeFilterActionBar:
                cells.append(.button(actionBar.button, surface: nil))
            default:
                break
            }
        }
        return cells
    }

    private func makeSelectedCategoryChip(category: StoreFoodCategoryResponse, fontColor: String) -> SDChip {
        SDChip(
            image: SDImage(url: category.imageUrl, style: SDImageStyle(width: 16, height: 16)),
            text: SDText(text: category.name, isHtml: false, fontColor: fontColor),
            style: nil
        )
    }

    private func makeFallbackFilterDatasource() -> [HomeFilterCollectionView.CellType] {
        let categoriesChip = SDChip(
            image: nil,
            text: SDText(text: "음식 종류", isHtml: false, fontColor: "#5A5A5A"),
            style: nil
        )
        var cells: [HomeFilterCollectionView.CellType] = [
            .chip(categoriesChip, action: .openCategoryFilter)
        ]
        if let category = state.categoryFilter {
            let chip = makeSelectedCategoryChip(category: category, fontColor: "#000000")
            cells.append(.selectedCategoryChip(chip, current: nil))
        }
        return cells
    }
}

// MARK: Log
extension HomeViewModel {
    private func sendClickHomeCardLog() {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .card,
            objectId: .store
        ))
    }

    private func sendClickCurrentLocationLog() {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .currentLocation
        ))
    }

    private func sendClickAddressLog() {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .address
        ))
    }

    private func sendClickCategoryFilterLog() {
        if let clickLog = allBars
            .compactMap({ $0 as? HomeFilterCategoryBar })
            .first?
            .categoriesFilterClickLog {
            dependency.logManager.sendEvent(event: ClickEvent(clickLog: clickLog))
            return
        }
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .categoryFilter
        ))
    }

    private func sendClickOnlyBossFilterLog(isOn: Bool) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .bossFilter,
            extraParameters: [.value: isOn]
        ))
    }

    private func sendClickSortingFilterLog(sortType: StoreSortType) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .sorting,
            extraParameters: [.value: sortType.rawValue]
        ))
    }

    private func sendClickAdMarker(advertisement: AdvertisementResponse) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .marker,
            objectId: .advertisement,
            extraParameters: [.advertisementId: "\(advertisement.advertisementId)"]
        ))
    }

    private func sendClickRecentActivityFilter(isOn: Bool) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .recentActivityFilter,
            extraParameters: [.value: isOn]
        ))
    }

    private func sendClickMarkerLog() {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .marker,
            objectId: .store
        ))
    }

    private func sendClickFeedButtonLog() {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .feed
        ))
    }
}

extension HomeViewModel: HomeFilterSelectable {
    var onTapCategoryFilter: PassthroughSubject<Void, Never> {
        input.onTapCategoryFilter
    }

    var onTapRadioOption: PassthroughSubject<(paramKey: String, optionIndex: Int), Never> {
        input.onTapRadioOption
    }

    var onTapActionLink: PassthroughSubject<SDLink, Never> {
        input.onTapActionLink
    }

    var onTapCloseSelectedCategory: PassthroughSubject<Void, Never> {
        input.onTapCloseSelectedCategory
    }

    var selectCategory: PassthroughSubject<StoreFoodCategoryResponse?, Never> {
        input.selectCategory
    }

    var filterDatasource: CurrentValueSubject<[HomeFilterCollectionView.CellType], Never> {
        output.filterDatasource
    }
}
