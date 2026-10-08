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
        let didTapMapView = PassthroughSubject<Void, Never>()
        let setTabSection = PassthroughSubject<HomeBottomSheetTabSection?, Never>()
        let didTapTab = PassthroughSubject<Int, Never>()
        let setCurationLocation = PassthroughSubject<CLLocation, Never>()
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
        let didTapMapView = PassthroughSubject<Void, Never>()
        let tabs = CurrentValueSubject<[HomeBottomSheetTabItem], Never>([])
        let selectedViewType = CurrentValueSubject<HomeBottomTabViewType, Never>(.storeList)
    }

    struct State {
        var cards: [any HomeListCardComponent] = []
        var tabs: [HomeBottomTab] = []
        var selectedTabId: String?
    }

    public struct Config {
        public init() { }
    }

    struct Dependency {
        let screenRepository: ScreenRepository
        let logManager: LogManagerProtocol

        init(
            screenRepository: ScreenRepository = ScreenRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.screenRepository = screenRepository
            self.logManager = logManager
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
            .subscribe(output.resetList)
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

        input.setCurationLocation
            .subscribe(curationViewModel.input.setLocation)
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
        output.tabs.send(state.tabs.map { HomeBottomSheetTabItem(tab: $0, isSelected: $0.tabId == selectedTab?.tabId) })

        let viewType = selectedTab?.viewType ?? .storeList
        if output.selectedViewType.value != viewType {
            output.selectedViewType.send(viewType)
        }
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
}
