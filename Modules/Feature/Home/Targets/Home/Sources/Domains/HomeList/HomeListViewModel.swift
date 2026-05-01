import Foundation
import UIKit
import Combine
import CoreLocation

import Networking
import Common
import Model
import Log
import AppInterface

extension HomeListViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let willDisplay = PassthroughSubject<Int, Never>()
        let onTapCategoryFilter = PassthroughSubject<Void, Never>()
        let onTapRadioOption = PassthroughSubject<(paramKey: String, optionIndex: Int), Never>()
        let onTapActionLink = PassthroughSubject<SDLink, Never>()
        let onTapCloseSelectedCategory = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<StoreFoodCategoryResponse?, Never>()
        let onToggleCertifiedStore = PassthroughSubject<Void, Never>()
        let onTapStore = PassthroughSubject<StoreWithExtraResponse, Never>()
        let onTapAdvertisement = PassthroughSubject<AdvertisementResponse?, Never>()
    }

    struct Output {
        let screenName: ScreenName = .homeList
        let dataSource = CurrentValueSubject<[HomeListSection], Never>([])
        let filterDatasource: CurrentValueSubject<[HomeFilterCollectionView.CellType], Never>
        let categoryFilter: CurrentValueSubject<StoreFoodCategoryResponse?, Never>
        let isOnlyBoss: CurrentValueSubject<Bool, Never>
        let isOnlyCertified = CurrentValueSubject<Bool, Never>(false)
        let route = PassthroughSubject<Route, Never>()

        // To HomeViewModel
        let onSelectCategoryFilter = PassthroughSubject<StoreFoodCategoryResponse?, Never>()
        let onTapRadioOption = PassthroughSubject<(paramKey: String, optionIndex: Int), Never>()
    }

    struct State {
        var stores: [StoreWithExtraResponse] = []
        var categoryFilter: StoreFoodCategoryResponse?
        // 정적 typed targetStores 와 output.isOnlyBoss 용. SDU radioSelection["targetStores"] 와 동기화된다.
        var isOnlyBossStore: Bool
        // SDU 가 아닌 리스트 화면 전용 토글 (인증 가게만). dynamicParams 로 주입.
        var isOnlyCertifiedStore = false
        var mapLocation: CLLocation?
        var nextCursor: String?
        var hasMore: Bool
        let mapMaxDistance: Double?
        var advertisement: AdvertisementResponse?
        // 홈 화면에서 받은 SDU 필터 스냅샷. chip 렌더링과 dynamicParams 합성의 단일 출처.
        var filterSections: [any HomeScreenSection] = []
        var radioSelection: [String: Int] = [:]
    }

    struct Config {
        let categoryFilter: StoreFoodCategoryResponse?
        let isOnlyBossStore: Bool
        let mapLocation: CLLocation?
        let mapMaxDistance: Double?
        let filterSections: [any HomeScreenSection]
        let radioSelection: [String: Int]

        public init(
            categoryFilter: StoreFoodCategoryResponse?,
            isOnlyBossStore: Bool,
            mapLocation: CLLocation?,
            mapMaxDistance: Double?,
            filterSections: [any HomeScreenSection] = [],
            radioSelection: [String: Int] = [:]
        ) {
            self.categoryFilter = categoryFilter
            self.isOnlyBossStore = isOnlyBossStore
            self.mapLocation = mapLocation
            self.mapMaxDistance = mapMaxDistance
            self.filterSections = filterSections
            self.radioSelection = radioSelection
        }
    }

    enum Route {
        case pushStoreDetail(storeId: String)
        case pushBossStoreDetail(storeId: String)
        case showErrorAlert(Error)
        case presentCategoryFilter(CategoryFilterViewModel)
        case openUrl(String?)
    }

    struct Dependency {
        let storeRepository: StoreRepository
        let advertisementRepository: AdvertisementRepository
        let logManager: LogManagerProtocol
        let deepLinkHandler: DeepLinkHandlerProtocol

        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            advertisementRepository: AdvertisementRepository =  AdvertisementRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            deepLinkHandler: DeepLinkHandlerProtocol = Environment.appModuleInterface.deepLinkHandler
        ) {
            self.storeRepository = storeRepository
            self.advertisementRepository = advertisementRepository
            self.logManager = logManager
            self.deepLinkHandler = deepLinkHandler
        }
    }
}

final class HomeListViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    private let dependency: Dependency

    init(config: Config, dependency: Dependency = Dependency()) {
        let initialDatasource = HomeListViewModel.makeFilterDatasource(
            filterSections: config.filterSections,
            radioSelection: config.radioSelection,
            categoryFilter: config.categoryFilter
        )
        self.output = Output(
            filterDatasource: .init(initialDatasource),
            categoryFilter: .init(config.categoryFilter),
            isOnlyBoss: .init(config.isOnlyBossStore)
        )
        self.state = State(
            categoryFilter: config.categoryFilter,
            isOnlyBossStore: config.isOnlyBossStore,
            mapLocation: config.mapLocation,
            hasMore: true,
            mapMaxDistance: config.mapMaxDistance,
            filterSections: config.filterSections,
            radioSelection: config.radioSelection
        )
        self.dependency = dependency
        super.init()

        bindRelay()
    }

    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, _) in
                owner.fetchDatas()
            }
            .store(in: &cancellables)

        input.willDisplay
            .removeDuplicates()
            .withUnretained(self)
            .filter { owner, index in
                owner.canLoad(index: index)
            }
            .sink(receiveValue: { (owner: HomeListViewModel, _) in
                owner.fetchAroundStore()
            })
            .store(in: &cancellables)

        input.onTapCategoryFilter
            .withUnretained(self)
            .sink { owner, _ in
                owner.sendClickCategoryFilterLog()
                owner.presentCategoryFilter()
            }
            .store(in: &cancellables)

        input.selectCategory
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, category: StoreFoodCategoryResponse?) in
                owner.clearData()
                owner.state.categoryFilter = category
                owner.updateFilterDatasource()
                owner.fetchAroundStore()
            })
            .store(in: &cancellables)

        input.onToggleCertifiedStore
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, _) in
                owner.clearData()
                owner.state.isOnlyCertifiedStore.toggle()
                owner.sendClickOnlyVisitFilterLog(owner.state.isOnlyCertifiedStore)
                owner.output.isOnlyCertified.send(owner.state.isOnlyCertifiedStore)
                owner.fetchAroundStore()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)

        input.onTapStore
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, storeWithExtra: StoreWithExtraResponse) in
                owner.sendClickStore(storeWithExtra.store)

                switch storeWithExtra.store.storeType {
                case .bossStore:
                    owner.output.route.send(.pushBossStoreDetail(storeId: storeWithExtra.store.storeId))
                case .userStore:
                    owner.output.route.send(.pushStoreDetail(storeId: storeWithExtra.store.storeId))
                case .unknown:
                    break
                }
            })
            .store(in: &cancellables)

        input.onTapAdvertisement
            .withUnretained(self)
            .sink { owner, advertisement in
                guard let advertisement else { return }
                owner.sendClickAdBannerLog(advertisement)
                guard let link = advertisement.link else { return }
                owner.dependency.deepLinkHandler.handleAdvertisementLink(link)
            }
            .store(in: &cancellables)

        input.onTapRadioOption
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, payload: (paramKey: String, optionIndex: Int)) in
                owner.applyRadioSelection(paramKey: payload.paramKey, optionIndex: payload.optionIndex)
                owner.clearData()
                owner.fetchAroundStore()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)

        input.onTapActionLink
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, link: SDLink) in
                owner.sendActionBarClickLog(for: link)
                owner.dependency.deepLinkHandler.handleLinkResponse(link)
            })
            .store(in: &cancellables)

        input.onTapCloseSelectedCategory
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, _) in
                owner.sendCurrentCategoryCloseLog()
                owner.input.selectCategory.send(nil)
            })
            .store(in: &cancellables)
    }

    private func bindRelay() {
        input.selectCategory
            .subscribe(output.onSelectCategoryFilter)
            .store(in: &cancellables)

        input.onTapRadioOption
            .subscribe(output.onTapRadioOption)
            .store(in: &cancellables)
    }

    private func applyRadioSelection(paramKey: String, optionIndex: Int) {
        state.radioSelection[paramKey] = optionIndex
        let paramValue = currentParamValue(for: paramKey, fallbackOptionIndex: optionIndex)

        // 정적 typed targetStores 와 output.isOnlyBoss 가 SDU 선택과 어긋나지 않도록 동기화한다.
        if paramKey == "targetStores" {
            state.isOnlyBossStore = (paramValue == "BOSS_STORE")
            output.isOnlyBoss.send(state.isOnlyBossStore)
        }

        switch paramKey {
        case "filterConditions":
            sendClickRecentActivityFilter(value: paramValue == "RECENT_ACTIVITY")
        case "sortType":
            if let value = paramValue, let sortType = StoreSortType(rawValue: value) {
                sendClickSortingLog(sortType)
            }
        case "targetStores":
            sendClickOnlyBossFilterLog(paramValue == "BOSS_STORE")
        default:
            // 신규 paramKey 는 분석 이벤트 추가 시 case 분리.
            break
        }

        sendClickFilterLog(paramKey: paramKey, optionIndex: optionIndex)
    }

    private func sendClickFilterLog(paramKey: String, optionIndex: Int) {
        guard let radioBar = allBars
            .compactMap({ $0 as? HomeFilterRadioBar })
            .first(where: { $0.paramKey == paramKey }),
              let option = radioBar.options[safe: optionIndex],
              let clickLog = option.clickLog else { return }
        dependency.logManager.sendEvent(event: SDClickEvent(clickLog: clickLog))
    }

    private func sendActionBarClickLog(for link: SDLink) {
        let actionBar = allBars
            .compactMap { $0 as? HomeFilterActionBar }
            .first { $0.button.link == link }
        guard let clickLog = actionBar?.clickLog else { return }
        dependency.logManager.sendEvent(event: SDClickEvent(clickLog: clickLog))
    }

    private func sendCurrentCategoryCloseLog() {
        let currentCategory = allBars
            .compactMap { $0 as? HomeFilterCategoryBar }
            .first?
            .currentCategoryFilter
        guard let clickLog = currentCategory?.clickLog else { return }
        dependency.logManager.sendEvent(event: SDClickEvent(clickLog: clickLog))
    }

    /// SDU 응답에서 paramValue 를 우선 조회. 응답이 없으면 fallback chip 의 optionIndex(0/1) 로 추정한다.
    private func currentParamValue(for paramKey: String, fallbackOptionIndex: Int) -> String? {
        if let radioBar = allBars.compactMap({ $0 as? HomeFilterRadioBar }).first(where: { $0.paramKey == paramKey }),
           let value = radioBar.options[safe: fallbackOptionIndex]?.paramValue {
            return value
        }
        // 정적 fallback 매핑 (SDU 응답이 없을 때만 사용).
        switch paramKey {
        case "filterConditions":
            return fallbackOptionIndex == 1 ? "RECENT_ACTIVITY" : nil
        case "sortType":
            return fallbackOptionIndex == 1 ? "LATEST" : "DISTANCE_ASC"
        case "targetStores":
            return fallbackOptionIndex == 1 ? "BOSS_STORE" : nil
        default:
            return nil
        }
    }

    private var allBars: [any HomeFilterBar] {
        state.filterSections
            .compactMap { $0 as? HomeFilterSection }
            .flatMap(\.bars)
    }

    private func updateFilterDatasource() {
        let datasource = HomeListViewModel.makeFilterDatasource(
            filterSections: state.filterSections,
            radioSelection: state.radioSelection,
            categoryFilter: state.categoryFilter
        )
        output.filterDatasource.send(datasource)
        output.categoryFilter.send(state.categoryFilter)
        output.isOnlyBoss.send(state.isOnlyBossStore)
    }

    /// SDU 응답이 있으면 홈 화면과 동일한 chip 을 렌더하고, 없으면 정적 fallback 으로 합성한다.
    static func makeFilterDatasource(
        filterSections: [any HomeScreenSection],
        radioSelection: [String: Int],
        categoryFilter: StoreFoodCategoryResponse?
    ) -> [HomeFilterCollectionView.CellType] {
        let allBars = filterSections
            .compactMap { $0 as? HomeFilterSection }
            .flatMap(\.bars)

        guard allBars.isEmpty.isNot else {
            return makeFallbackDatasource(
                radioSelection: radioSelection,
                categoryFilter: categoryFilter
            )
        }

        var cells: [HomeFilterCollectionView.CellType] = []
        for bar in allBars {
            switch bar {
            case let categoryBar as HomeFilterCategoryBar:
                cells.append(.chip(categoryBar.categoriesFilter, surface: nil, action: .openCategoryFilter))
                if let category = categoryFilter {
                    let fontColor = categoryBar.currentCategoryFilter?.fontColor ?? "#000000"
                    let chip = makeSelectedCategoryChip(category: category, fontColor: fontColor)
                    cells.append(.selectedCategoryChip(chip, current: categoryBar.currentCategoryFilter))
                }
            case let radioBar as HomeFilterRadioBar:
                let selectedIndex = radioSelection[radioBar.paramKey] ?? 0
                guard radioBar.options.isEmpty.isNot,
                      let currentOption = radioBar.options[safe: selectedIndex] else { break }
                let nextIndex = (selectedIndex + 1) % radioBar.options.count
                let surface: SDSurfaceStyle? = selectedIndex == 0 ? nil : selectedSurface(for: currentOption.chip)
                let action = HomeFilterCollectionView.ChipAction.selectRadio(paramKey: radioBar.paramKey, optionIndex: nextIndex)
                cells.append(.chip(currentOption.chip, surface: surface, action: action))
            case let actionBar as HomeFilterActionBar:
                cells.append(.button(actionBar.button, surface: nil))
            default:
                break
            }
        }
        return cells
    }

    /// SDU 응답이 없을 때 사용. 활성/비활성 상태와 다음 optionIndex 모두 radioSelection 에서 직접 파생.
    private static func makeFallbackDatasource(
        radioSelection: [String: Int],
        categoryFilter: StoreFoodCategoryResponse?
    ) -> [HomeFilterCollectionView.CellType] {
        let isOnlyRecentActivity = (radioSelection["filterConditions"] ?? 0) == 1
        let isLatestSort = (radioSelection["sortType"] ?? 0) == 1
        let isOnlyBossStore = (radioSelection["targetStores"] ?? 0) == 1

        let categoriesChip = SDChip(
            image: nil,
            text: SDText(text: "음식 종류", isHtml: false, fontColor: "#5A5A5A"),
            style: nil
        )
        var cells: [HomeFilterCollectionView.CellType] = [
            .chip(categoriesChip, surface: nil, action: .openCategoryFilter)
        ]
        if let categoryFilter {
            let chip = makeSelectedCategoryChip(category: categoryFilter, fontColor: "#FF858F")
            cells.append(.chip(chip, surface: nil, action: .openCategoryFilter))
        }
        // optionIndex 는 "탭 후 전환될 다음 인덱스" 를 의미 (SDU chip 과 동일 규약).
        let recentActivityChip = SDChip(
            image: nil,
            text: SDText(text: "🔥 영업 중", isHtml: false, fontColor: isOnlyRecentActivity ? "#FF858F" : "#5A5A5A"),
            style: nil
        )
        cells.append(.chip(
            recentActivityChip,
            surface: nil,
            action: .selectRadio(paramKey: "filterConditions", optionIndex: isOnlyRecentActivity ? 0 : 1)
        ))
        let sortChip = SDChip(
            image: nil,
            text: SDText(text: isLatestSort ? "최신순" : "거리순", isHtml: false, fontColor: "#5A5A5A"),
            style: nil
        )
        cells.append(.chip(
            sortChip,
            surface: nil,
            action: .selectRadio(paramKey: "sortType", optionIndex: isLatestSort ? 0 : 1)
        ))
        let bossChip = SDChip(
            image: nil,
            text: SDText(text: "🧑‍🍳 사장님 직영", isHtml: false, fontColor: isOnlyBossStore ? "#FF858F" : "#5A5A5A"),
            style: nil
        )
        cells.append(.chip(
            bossChip,
            surface: nil,
            action: .selectRadio(paramKey: "targetStores", optionIndex: isOnlyBossStore ? 0 : 1)
        ))
        return cells
    }

    private static func selectedSurface(for chip: SDChip) -> SDSurfaceStyle? {
        guard let background = chip.style?.backgroundColor else { return nil }
        return SDSurfaceStyle(
            backgroundColor: background,
            borderColor: chip.text.fontColor,
            borderWidth: 1,
            cornerRadius: 10
        )
    }

    private static func makeSelectedCategoryChip(category: StoreFoodCategoryResponse, fontColor: String) -> SDChip {
        SDChip(
            image: SDImage(url: category.imageUrl, style: SDImageStyle(width: 16, height: 16)),
            text: SDText(text: category.name, isHtml: false, fontColor: fontColor),
            style: nil
        )
    }

    private func canLoad(index: Int) -> Bool {
        var contentsCount = state.stores.count
        contentsCount += 2 // 광고 카운트
        return index >= contentsCount - 1 && state.nextCursor != nil && state.hasMore
    }

    private func fetchAroundStore() {
        Task {
            let input = createFetchAroundStoreInput()
            let result = await dependency.storeRepository.fetchAroundStores(input: input)

            switch result {
            case .success(let response):
                state.hasMore = response.cursor.hasMore
                state.nextCursor = response.cursor.nextCursor
                state.stores.append(contentsOf: response.contents)
                updateDataSource()
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
        .store(in: taskBag)
    }

    private func createFetchAroundStoreInput() -> FetchAroundStoreInput {
        var categoryIds: [String]?
        if let filterCategory = state.categoryFilter {
            categoryIds = [filterCategory.categoryId]
        }
        let targetStores: [StoreType] = state.isOnlyBossStore ? [.bossStore] : [.userStore, .bossStore]

        return FetchAroundStoreInput(
            distanceM: state.mapMaxDistance ?? 0,
            categoryIds: categoryIds,
            targetStores: targetStores,
            size: 10,
            cursor: state.nextCursor,
            mapLatitude: state.mapLocation?.coordinate.latitude ?? 0,
            mapLongitude: state.mapLocation?.coordinate.longitude ?? 0,
            dynamicParams: collectDynamicParams()
        )
    }

    private func collectDynamicParams() -> [String: String] {
        var params: [String: String] = [:]
        let radioBars = allBars.compactMap { $0 as? HomeFilterRadioBar }

        if radioBars.isEmpty {
            // SDU 응답이 없을 때 fallback chip 의 선택 상태를 paramValue 로 매핑.
            for paramKey in ["filterConditions", "sortType"] {
                let idx = state.radioSelection[paramKey] ?? 0
                if let value = currentParamValue(for: paramKey, fallbackOptionIndex: idx) {
                    params[paramKey] = value
                }
            }
        } else {
            // targetStores 는 정적 typed 필드로 직렬화되므로 dynamicParams 에서 제외해 중복 쿼리 키를 막는다.
            for bar in radioBars where bar.paramKey != "targetStores" {
                let idx = state.radioSelection[bar.paramKey] ?? 0
                if let value = bar.options[safe: idx]?.paramValue {
                    params[bar.paramKey] = value
                }
            }
        }

        // SDU 와 무관한 리스트 전용 필터. true 일 때만 포함.
        if state.isOnlyCertifiedStore {
            params["filterCertifiedStores"] = "true"
        }

        // sortType 은 서버 required 필드. 어떤 경로로도 채워지지 않은 경우 기본값으로 보강.
        if params["sortType"] == nil {
            params["sortType"] = "DISTANCE_ASC"
        }
        return params
    }

    private func fetchDatas() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let advertisementInput = FetchAdvertisementInput(position: .storeList, size: nil)
                let advertisements = try await dependency.advertisementRepository.fetchAdvertisements(input: advertisementInput).get()

                state.advertisement = advertisements.advertisements.first

                let input = createFetchAroundStoreInput()
                let response = try await dependency.storeRepository.fetchAroundStores(input: input).get()

                state.hasMore = response.cursor.hasMore
                state.nextCursor = response.cursor.nextCursor
                state.stores.append(contentsOf: response.contents)
                updateDataSource()
            } catch {
                output.route.send(.showErrorAlert(error))
            }
        }
        .store(in: taskBag)
    }

    private func updateDataSource() {
        var sectionItems = state.stores.map { HomeListSectionItem.store($0) }

        if sectionItems.isEmpty {
            sectionItems.append(.emptyStore)
        }

        let admobIndex = min(0, sectionItems.count)
        sectionItems.insert(.admob, at: admobIndex)

        let index = min(1, sectionItems.count) // 두번째 구좌에 노출
        let config = HomeListAdCellViewModel.Config(ad: state.advertisement)
        let viewModel = HomeListAdCellViewModel(config: config)

        sectionItems.insert(.ad(viewModel), at: index)

        output.dataSource.send([HomeListSection(items: sectionItems)])
    }

    private func presentCategoryFilter() {
        let config = CategoryFilterViewModel.Config(currentCategory: state.categoryFilter)
        let viewModel = CategoryFilterViewModel(config: config)

        viewModel.output.didSelectCategory
            .subscribe(input.selectCategory)
            .store(in: &viewModel.cancellables)

        output.route.send(.presentCategoryFilter(viewModel))
    }

    private func clearData() {
        state.nextCursor = nil
        state.hasMore = false
        state.stores = []
    }
}

// MARK: Log
extension HomeListViewModel {
    private func sendClickStore(_ store: StoreResponse) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .card,
            objectId: .store,
            extraParameters: [
                .storeId: store.storeId,
                .type: store.storeType.rawValue
            ]
        ))
    }

    private func sendClickCategoryFilterLog() {
        if let clickLog = allBars
            .compactMap({ $0 as? HomeFilterCategoryBar })
            .first?
            .categoriesFilterClickLog {
            dependency.logManager.sendEvent(event: SDClickEvent(clickLog: clickLog))
            return
        }
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .categoryFilter
        ))
    }

    private func sendClickSortingLog(_ sortType: StoreSortType) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .sorting,
            extraParameters: [.value: sortType.rawValue]
        ))
    }

    private func sendClickAdBannerLog(_ advertisement: AdvertisementResponse) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .banner,
            objectId: .advertisement,
            extraParameters: [.advertisementId: "\(advertisement.advertisementId)"]
        ))
    }

    private func sendClickOnlyBossFilterLog(_ isOn: Bool) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .bossFilter,
            extraParameters: [.value: isOn]
        ))
    }

    private func sendClickOnlyVisitFilterLog(_ isOn: Bool) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .onlyVisit,
            extraParameters: [.value: isOn]
        ))
    }

    private func sendClickRecentActivityFilter(value: Bool) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .recentActivityFilter,
            extraParameters: [.value: value]
        ))
    }
}

extension HomeListViewModel: HomeFilterSelectable {
    var onTapCategoryFilter: PassthroughSubject<Void, Never> {
        return input.onTapCategoryFilter
    }

    var onTapRadioOption: PassthroughSubject<(paramKey: String, optionIndex: Int), Never> {
        return input.onTapRadioOption
    }

    var onTapActionLink: PassthroughSubject<SDLink, Never> {
        return input.onTapActionLink
    }

    var onTapCloseSelectedCategory: PassthroughSubject<Void, Never> {
        return input.onTapCloseSelectedCategory
    }

    var selectCategory: PassthroughSubject<StoreFoodCategoryResponse?, Never> {
        return input.selectCategory
    }

    var filterDatasource: CurrentValueSubject<[HomeFilterCollectionView.CellType], Never> {
        return output.filterDatasource
    }
}
