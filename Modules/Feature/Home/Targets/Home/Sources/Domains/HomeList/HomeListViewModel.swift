import Foundation
import Combine
import CoreLocation

import Common
import Model
import Networking
import Log

extension HomeListViewModel {
    struct Input {
        let updateCards = PassthroughSubject<[any HomeListCardComponent], Never>()
        let didReplaceCards = PassthroughSubject<Void, Never>()
        let willDisplay = PassthroughSubject<Int, Never>()
        let didTapCard = PassthroughSubject<Int, Never>()
        let didTapImage = PassthroughSubject<(images: [SDImage], index: Int), Never>()
        let didTapFavorite = PassthroughSubject<String, Never>()
        let updateFavorite = PassthroughSubject<(storeId: String, isFavorited: Bool), Never>()
        let didTapMapView = PassthroughSubject<Void, Never>()
        let setTabSection = PassthroughSubject<HomeBottomSheetTabSection?, Never>()
        let didTapTab = PassthroughSubject<Int, Never>()
        let setMapLocation = PassthroughSubject<CLLocation, Never>()
        let receiveSectionImpressionLog = PassthroughSubject<SDImpressionLog, Never>()
    }

    struct Output {
        let screenName: ScreenName = .home
        let dataSource = CurrentValueSubject<[HomeListSection], Never>([])
        let resetList = PassthroughSubject<Void, Never>()
        /// 부모(HomeViewModel) 가 fetchMore 를 트리거하도록 알린다.
        let willLoadMore = PassthroughSubject<Void, Never>()
        /// 부모(HomeViewModel) 가 카드 탭 라우팅을 처리하도록 인덱스 를 전달한다.
        let didTapCardAt = PassthroughSubject<Int, Never>()
        let didTapImageAt = PassthroughSubject<(images: [SDImage], index: Int), Never>()
        let favoriteUpdated = PassthroughSubject<String, Never>()
        let toast = PassthroughSubject<String, Never>()
        let didTapMapView = PassthroughSubject<Void, Never>()
        let tabs = CurrentValueSubject<[HomeBottomSheetTabItem], Never>([])
        let selectedViewType = CurrentValueSubject<HomeBottomTabViewType, Never>(.storeList)
        let didSelectCurationStore = PassthroughSubject<HomeCurationSelectedStore, Never>()
        let loadNews = PassthroughSubject<CLLocation, Never>()
    }

    struct State {
        var cards: [any HomeListCardComponent] = []
        var tabs: [HomeBottomTab] = []
        var selectedTabId: String?
        var pendingSectionImpressionLog: SDImpressionLog?
        var mapLocation: CLLocation?
        var newsLoadedLocation: CLLocation?
        var latestNewsFeedId: String?
        var favoriteOverrides: [String: Bool] = [:]
        var favoriteRequestingStoreIds: Set<String> = []
    }

    public struct Config {
        public init() { }
    }

    struct Dependency {
        let screenRepository: ScreenRepository
        let storeRepository: StoreRepository
        let feedRepository: FeedRepository
        let logManager: LogManagerProtocol
        let preference: Preference

        init(
            screenRepository: ScreenRepository = ScreenRepositoryImpl(),
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            feedRepository: FeedRepository = FeedRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            preference: Preference = .shared
        ) {
            self.screenRepository = screenRepository
            self.storeRepository = storeRepository
            self.feedRepository = feedRepository
            self.logManager = logManager
            self.preference = preference
        }
    }
}

final class HomeListViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: Dependency
    let curationViewModel: HomeCurationViewModel

    init(config: Config = Config(), dependency: Dependency = Dependency()) {
        self.dependency = dependency
        self.curationViewModel = HomeCurationViewModel(dependency: .init(
            screenRepository: dependency.screenRepository,
            storeRepository: dependency.storeRepository,
            logManager: dependency.logManager
        ))
        super.init()
    }

    override func bind() {
        input.updateCards
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, cards: [any HomeListCardComponent]) in
                owner.state.cards = cards
                owner.emitDataSource()
            }
            .store(in: &cancellables)

        input.didReplaceCards
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, _) in
                owner.state.favoriteOverrides.removeAll()
                owner.output.resetList.send(())
            }
            .store(in: &cancellables)

        input.updateFavorite
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, favorite: (storeId: String, isFavorited: Bool)) in
                guard owner.isFavorited(storeId: favorite.storeId) != favorite.isFavorited else { return }
                owner.state.favoriteOverrides[favorite.storeId] = favorite.isFavorited
                owner.output.favoriteUpdated.send(favorite.storeId)
            }
            .store(in: &cancellables)

        input.didTapFavorite
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, cardId: String) in
                owner.toggleFavorite(cardId: cardId)
            }
            .store(in: &cancellables)

        input.willDisplay
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, index: Int) in
                owner.handleWillDisplay(at: index)
            }
            .store(in: &cancellables)

        input.didTapCard
            .subscribe(output.didTapCardAt)
            .store(in: &cancellables)

        input.didTapImage
            .subscribe(output.didTapImageAt)
            .store(in: &cancellables)

        input.receiveSectionImpressionLog
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, impressionLog: SDImpressionLog) in
                owner.state.pendingSectionImpressionLog = impressionLog
                owner.sendSectionImpressionLogIfVisible()
            }
            .store(in: &cancellables)

        input.didTapMapView
            .withUnretained(self)
            .handleEvents(receiveOutput: { (owner: HomeListViewModel, _) in
                owner.sendClickMapViewLog()
            })
            .map { _ in () }
            .subscribe(output.didTapMapView)
            .store(in: &cancellables)

        bindTabs()
    }

    private func bindTabs() {
        input.setTabSection
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, section: HomeBottomSheetTabSection?) in
                owner.applyTabSection(section)
            }
            .store(in: &cancellables)

        input.didTapTab
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, index: Int) in
                owner.selectTab(at: index)
            }
            .store(in: &cancellables)

        input.setMapLocation
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, location: CLLocation) in
                owner.curationViewModel.input.setLocation.send(location)
                owner.state.mapLocation = location
                owner.state.latestNewsFeedId = nil
                owner.loadNewsIfVisible()
                owner.fetchLatestNewsFeedIdIfNeeded()
            }
            .store(in: &cancellables)

        curationViewModel.output.didSelectStore
            .subscribe(output.didSelectCurationStore)
            .store(in: &cancellables)
    }

    private func applyTabSection(_ section: HomeBottomSheetTabSection?) {
        let tabs = (section?.tabs ?? []).filter { $0.viewType != .unknown }
        state.tabs = tabs

        if let selectedTabId = state.selectedTabId, tabs.contains(where: { $0.tabId == selectedTabId }) {
            emitTabs()
            return
        }
        let defaultTab = tabs.first(where: \.defaultSelected) ?? tabs.first
        state.selectedTabId = defaultTab?.tabId
        emitTabs()
        fetchLatestNewsFeedIdIfNeeded()
    }

    private func selectTab(at index: Int) {
        guard let tab = state.tabs[safe: index], tab.tabId != state.selectedTabId else { return }
        dependency.logManager.sendEvent(event: ClickEvent(clickLog: tab.clickLog))
        state.selectedTabId = tab.tabId
        emitTabs()
    }

    private func emitTabs() {
        let selectedTab = state.tabs.first { $0.tabId == state.selectedTabId }
        let curationTabId = selectedTab?.viewType == .curation ? selectedTab?.tabId : nil
        curationViewModel.input.setTabId.send(curationTabId)

        let viewType = selectedTab?.viewType ?? .storeList
        if output.selectedViewType.value != viewType {
            output.selectedViewType.send(viewType)
        }
        markNewsSeenIfVisible()
        emitTabItems()
        loadNewsIfVisible()
        sendSectionImpressionLogIfVisible()
    }

    private func emitTabItems() {
        output.tabs.send(state.tabs.map {
            HomeBottomSheetTabItem(
                tab: $0,
                isSelected: $0.tabId == state.selectedTabId,
                hasNewBadge: $0.viewType == .news && $0.tabId != state.selectedTabId && hasUnseenNews
            )
        })
    }

    private var hasUnseenNews: Bool {
        guard let latestNewsFeedId = state.latestNewsFeedId else { return false }
        guard let lastSeenFeedId = dependency.preference.lastSeenLocalNewsFeedId else { return true }
        return latestNewsFeedId > lastSeenFeedId
    }

    private var hasNewsTab: Bool {
        state.tabs.contains { $0.viewType == .news }
    }

    private func markNewsSeenIfVisible() {
        guard output.selectedViewType.value == .news, hasUnseenNews else { return }
        dependency.preference.lastSeenLocalNewsFeedId = state.latestNewsFeedId
    }

    private func loadNewsIfVisible() {
        guard output.selectedViewType.value == .news,
              let location = state.mapLocation,
              isSameCoordinate(state.newsLoadedLocation, location).isNot else { return }
        state.newsLoadedLocation = location
        output.loadNews.send(location)
    }

    private func fetchLatestNewsFeedIdIfNeeded() {
        guard hasNewsTab, state.latestNewsFeedId == nil, let location = state.mapLocation else { return }

        Task { @MainActor [weak self] in
            guard let self else { return }
            let input = FetchFeedInput(
                size: 1,
                mapLatitude: location.coordinate.latitude,
                mapLongitude: location.coordinate.longitude
            )
            let result = await dependency.feedRepository.fetchFeed(input: input)
            guard isSameCoordinate(state.mapLocation, location),
                  case .success(let response) = result else { return }
            state.latestNewsFeedId = response.contents.first?.feedId
            markNewsSeenIfVisible()
            emitTabItems()
        }
    }

    private func isSameCoordinate(_ lhs: CLLocation?, _ rhs: CLLocation) -> Bool {
        guard let lhs else { return false }
        return lhs.coordinate.latitude == rhs.coordinate.latitude
            && lhs.coordinate.longitude == rhs.coordinate.longitude
    }

    private func sendSectionImpressionLogIfVisible() {
        guard output.selectedViewType.value == .storeList,
              let impressionLog = state.pendingSectionImpressionLog else { return }
        state.pendingSectionImpressionLog = nil
        dependency.logManager.sendEvent(event: ImpressionEvent(impressionLog: impressionLog))
    }

    func isFavorited(_ card: HomeListBasicCardResponse) -> Bool {
        guard let storeId = card.additionalInfos?.storeId else { return false }
        return state.favoriteOverrides[storeId] ?? card.additionalInfos?.isSubscriber ?? false
    }

    private func isFavorited(storeId: String) -> Bool {
        if let override = state.favoriteOverrides[storeId] {
            return override
        }
        let card = state.cards
            .compactMap { $0 as? HomeListBasicCardResponse }
            .first { $0.additionalInfos?.storeId == storeId }
        return card?.additionalInfos?.isSubscriber ?? false
    }

    private func toggleFavorite(cardId: String) {
        guard let card = state.cards.first(where: { $0.cardId == cardId }) as? HomeListBasicCardResponse,
              let storeId = card.additionalInfos?.storeId,
              state.favoriteRequestingStoreIds.insert(storeId).inserted else { return }

        let isDelete = isFavorited(card)
        sendClickFavoriteLog(card: card, isOn: isDelete.isNot)

        Task { @MainActor [weak self] in
            guard let self else { return }
            let result = await dependency.storeRepository.saveStore(storeId: storeId, isDelete: isDelete)
            state.favoriteRequestingStoreIds.remove(storeId)

            guard case .success = result else { return }
            state.favoriteOverrides[storeId] = isDelete.isNot
            output.favoriteUpdated.send(storeId)
            output.toast.send(isDelete ? HomeStrings.HomeList.Toast.removeFavorite : HomeStrings.HomeList.Toast.addFavorite)
        }
        .store(in: taskBag)
    }

    private func emitDataSource() {
        // DiffableDataSource 는 중복 identifier 가 들어오면 crash 하므로,
        // cardId 기준으로 한 번 더 디듭해 스냅샷에 같은 카드가 두 번 들어가지 않게 한다.
        var seenIds = Set<String>()
        var items: [HomeListSectionItem] = []
        for card in state.cards where seenIds.insert(card.cardId).inserted {
            if let basic = card as? HomeListBasicCardResponse {
                items.append(.basicCard(basic))
            } else if let admob = card as? HomeListAdmobCardResponse {
                items.append(.admobCard(admob))
            } else if let empty = card as? HomeListEmptyCardResponse {
                items.append(.emptyCard(empty))
            } else if let adCard = card as? SDAdCard {
                items.append(.adCard(adCard))
            }
        }
        output.dataSource.send([HomeListSection(items: items)])
    }

    private func handleWillDisplay(at index: Int) {
        guard let card = state.cards[safe: index] else { return }

        // willDisplay 시점마다 impression 로그를 발사한다 (1회 디듭 X).
        let log: SDImpressionLog?
        switch card {
        case let basic as HomeListBasicCardResponse:
            log = basic.impressionLog
        case let admob as HomeListAdmobCardResponse:
            log = admob.impressionLog
        case let empty as HomeListEmptyCardResponse:
            log = empty.impressionLog
        case let adCard as SDAdCard:
            log = adCard.impressionLog
        default:
            log = nil
        }
        if let log {
            dependency.logManager.sendEvent(event: ImpressionEvent(impressionLog: log))
        }

        // 마지막 셀이 보이면 부모에게 더 가져오라고 알린다.
        if index >= state.cards.count - 1 {
            output.willLoadMore.send(())
        }
    }
}

// MARK: Log
extension HomeListViewModel {
    private func sendClickMapViewLog() {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .mapView
        ))
    }

    private func sendClickFavoriteLog(card: HomeListBasicCardResponse, isOn: Bool) {
        var extraParameters: [ParameterName: Any] = [.value: isOn ? "on" : "off"]
        extraParameters[.storeId] = card.additionalInfos?.storeId
        extraParameters[.storeType] = card.additionalInfos?.storeType
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .favorite,
            extraParameters: extraParameters
        ))
    }
}
