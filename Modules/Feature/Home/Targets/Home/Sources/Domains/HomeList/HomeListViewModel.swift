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
        let onTapOnlyRecentActivity = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<StoreFoodCategoryResponse?, Never>()
        let onToggleSort = PassthroughSubject<StoreSortType, Never>()
        let onTapOnlyBoss = PassthroughSubject<Void, Never>()
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
        let onToggleSort = PassthroughSubject<StoreSortType, Never>()
        let onTapOnlyBoss = PassthroughSubject<Void, Never>()
        let onTapOnlyRecentActivity = PassthroughSubject<Void, Never>()
    }

    struct State {
        var stores: [StoreWithExtraResponse] = []
        var categoryFilter: StoreFoodCategoryResponse?
        var isOnlyRecentActivity: Bool
        var sortType: StoreSortType
        var isOnlyBossStore: Bool
        var isOnlyCertifiedStore = false
        var mapLocation: CLLocation?
        var nextCursor: String?
        var hasMore: Bool
        let mapMaxDistance: Double?
        var advertisement: AdvertisementResponse?
    }

    struct Config {
        let categoryFilter: StoreFoodCategoryResponse?
        let isOnlyRecentActivity: Bool
        let sortType: StoreSortType
        let isOnlyBossStore: Bool
        let mapLocation: CLLocation?
        let mapMaxDistance: Double?
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
            categoryFilter: config.categoryFilter,
            isOnlyRecentActivity: config.isOnlyRecentActivity,
            sortType: config.sortType,
            isOnlyBossStore: config.isOnlyBossStore
        )
        self.output = Output(
            filterDatasource: .init(initialDatasource),
            categoryFilter: .init(config.categoryFilter),
            isOnlyBoss: .init(config.isOnlyBossStore)
        )
        self.state = State(
            categoryFilter: config.categoryFilter,
            isOnlyRecentActivity: config.isOnlyRecentActivity,
            sortType: config.sortType,
            isOnlyBossStore: config.isOnlyBossStore,
            mapLocation: config.mapLocation,
            hasMore: true,
            mapMaxDistance: config.mapMaxDistance
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

        input.onTapOnlyRecentActivity
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, _) in
                owner.state.isOnlyRecentActivity.toggle()
                owner.clearData()
                owner.sendClickRecentActivityFilter(value: owner.state.isOnlyRecentActivity)
                owner.fetchAroundStore()
                owner.updateFilterDatasource()
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

        input.onToggleSort
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, _: StoreSortType) in
                owner.clearData()
                owner.state.sortType = owner.state.sortType.toggled()
                owner.sendClickSortingLog(owner.state.sortType)
                owner.fetchAroundStore()
                owner.updateFilterDatasource()
            })
            .store(in: &cancellables)

        input.onTapOnlyBoss
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, _) in
                owner.clearData()
                owner.state.isOnlyBossStore.toggle()
                owner.sendClickOnlyBossFilterLog(owner.state.isOnlyBossStore)
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
                // chip 탭을 기존 typed input 으로 라우팅 — 기존 처리 흐름 재사용
                switch payload.paramKey {
                case "filterConditions":
                    owner.input.onTapOnlyRecentActivity.send(())
                case "sortType":
                    owner.input.onToggleSort.send(owner.state.sortType)
                case "targetStores":
                    owner.input.onTapOnlyBoss.send(())
                default:
                    break
                }
            })
            .store(in: &cancellables)

        input.onTapActionLink
            .withUnretained(self)
            .sink(receiveValue: { (owner: HomeListViewModel, link: SDLink) in
                owner.dependency.deepLinkHandler.handleLinkResponse(link)
            })
            .store(in: &cancellables)
    }

    private func bindRelay() {
        input.onToggleSort
            .subscribe(output.onToggleSort)
            .store(in: &cancellables)

        input.onTapOnlyBoss
            .subscribe(output.onTapOnlyBoss)
            .store(in: &cancellables)

        input.selectCategory
            .subscribe(output.onSelectCategoryFilter)
            .store(in: &cancellables)

        input.onTapOnlyRecentActivity
            .subscribe(output.onTapOnlyRecentActivity)
            .store(in: &cancellables)
    }

    private func updateFilterDatasource() {
        let datasource = HomeListViewModel.makeFilterDatasource(
            categoryFilter: state.categoryFilter,
            isOnlyRecentActivity: state.isOnlyRecentActivity,
            sortType: state.sortType,
            isOnlyBossStore: state.isOnlyBossStore
        )
        output.filterDatasource.send(datasource)
        output.categoryFilter.send(state.categoryFilter)
        output.isOnlyBoss.send(state.isOnlyBossStore)
    }

    /// 정적 fallback chip 합성 — HomeListViewController 의 필터 영역도 chip 기반으로 렌더하기 위해.
    /// SDUI 가 본 화면용으로 분리되기 전까지 사용.
    static func makeFilterDatasource(
        categoryFilter: StoreFoodCategoryResponse?,
        isOnlyRecentActivity: Bool,
        sortType: StoreSortType,
        isOnlyBossStore: Bool
    ) -> [HomeFilterCollectionView.CellType] {
        let categoriesChip = SDChip(
            image: nil,
            text: SDText(text: "음식 종류", isHtml: false, fontColor: "#5A5A5A"),
            style: nil
        )
        var cells: [HomeFilterCollectionView.CellType] = [
            .chip(categoriesChip, surface: nil, action: .openCategoryFilter)
        ]
        if let categoryFilter {
            let chip = SDChip(
                image: SDImage(url: categoryFilter.imageUrl, style: SDImageStyle(width: 16, height: 16)),
                text: SDText(text: categoryFilter.name, isHtml: false, fontColor: "#FF858F"),
                style: nil
            )
            cells.append(.chip(chip, surface: nil, action: .openCategoryFilter))
        }
        // 영업중 (filterConditions): paramValue=null 전체, "RECENT_ACTIVITY" 영업중
        let recentActivityChip = SDChip(
            image: nil,
            text: SDText(text: "🔥 영업 중", isHtml: false, fontColor: isOnlyRecentActivity ? "#FF858F" : "#5A5A5A"),
            style: nil
        )
        cells.append(.chip(
            recentActivityChip,
            surface: nil,
            action: .selectRadio(paramKey: "filterConditions", optionIndex: isOnlyRecentActivity ? 1 : 0)
        ))
        // 정렬 (sortType)
        let sortChip = SDChip(
            image: nil,
            text: SDText(text: sortType == .distanceAsc ? "거리순" : "최신순", isHtml: false, fontColor: "#5A5A5A"),
            style: nil
        )
        cells.append(.chip(
            sortChip,
            surface: nil,
            action: .selectRadio(paramKey: "sortType", optionIndex: sortType == .distanceAsc ? 0 : 1)
        ))
        // 사장님 직영점 (targetStores)
        let bossChip = SDChip(
            image: nil,
            text: SDText(text: "🧑‍🍳 사장님 직영", isHtml: false, fontColor: isOnlyBossStore ? "#FF858F" : "#5A5A5A"),
            style: nil
        )
        cells.append(.chip(
            bossChip,
            surface: nil,
            action: .selectRadio(paramKey: "targetStores", optionIndex: isOnlyBossStore ? 1 : 0)
        ))
        return cells
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
        let filterConditions: [ActivitiesStatus] = state.isOnlyRecentActivity ? [.recentActivity] : [.recentActivity, .noRecentActivity]

        return FetchAroundStoreInput(
            distanceM: state.mapMaxDistance ?? 0,
            categoryIds: categoryIds,
            targetStores: targetStores,
            sortType: state.sortType,
            filterCertifiedStores: state.isOnlyCertifiedStore,
            filterConditions: filterConditions,
            size: 10,
            cursor: state.nextCursor,
            mapLatitude: state.mapLocation?.coordinate.latitude ?? 0,
            mapLongitude: state.mapLocation?.coordinate.longitude ?? 0
        )
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

    var selectCategory: PassthroughSubject<StoreFoodCategoryResponse?, Never> {
        return input.selectCategory
    }

    var filterDatasource: CurrentValueSubject<[HomeFilterCollectionView.CellType], Never> {
        return output.filterDatasource
    }
}
