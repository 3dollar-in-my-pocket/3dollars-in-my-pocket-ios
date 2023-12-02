import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class CommunityViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let viewWillAppear = PassthroughSubject<Void, Never>()
        let didTapPollCategoryButton = PassthroughSubject<Void, Never>()
        let didSelectPollItem = PassthroughSubject<String, Never>()
        let didTapDistrictButton = PassthroughSubject<Void, Never>()
        let didSelect = PassthroughSubject<IndexPath, Never>()
    }

    struct Output {
        let screenName: ScreenName = .community
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let sections = CurrentValueSubject<[CommunitySection], Never>([])
        let updatePopularStores = PassthroughSubject<Void, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    struct State {
        let storeList = CurrentValueSubject<[PlatformStore], Never>([])
        let reload = PassthroughSubject<Void, Never>()
        let currentStoreTab = CurrentValueSubject<CommunityPopularStoreTab, Never>(.defaultTab)
    }

    enum Route {
        case pollCategoryTab(PollCategoryTabViewModel)
        case pollDetail(PollDetailViewModel)
        case popularStoreNeighborhoods(CommunityPopularStoreNeighborhoodsViewModel)
        case storeDetail(Int)
        case bossStoreDetail(String)
    }

    let input = Input()
    let output = Output()

    private var state = State()

    private let communityService: CommunityServiceProtocol
    private let userDefaultsUtil: UserDefaultsUtil
    private let logManager: LogManagerProtocol

    private lazy var pollListCellViewModel = bindPollListCellViewModel()
    private lazy var storeTabCellViewModel = bindPopularStoreTabCellViewModel()

    init(
        communityService: CommunityServiceProtocol = CommunityService(),
        userDefaultsUtil: UserDefaultsUtil = .shared,
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.communityService = communityService
        self.userDefaultsUtil = userDefaultsUtil
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()

        input.firstLoad
            .merge(with: state.reload)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .map { (owner: CommunityViewModel, _: Void) in
                return FetchPopularStoresInput(
                    criteria: owner.state.currentStoreTab.value.rawValue,
                    district: owner.userDefaultsUtil.communityPopularStoreNeighborhoods.district
                )
            }
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.communityService.fetchPopularStores(input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.state.storeList.send(response.contents.map {
                        PlatformStore(response: $0)
                    })
                    if response.contents.isEmpty {
                        owner.output.showToast.send("데이터가 없어요!")
                    }
                    owner.reloadDataSource()
                case .failure(let error):
                    owner.output.showToast.send(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
        
        input.viewWillAppear
            .withUnretained(self)
            .sink { (owner: CommunityViewModel, _) in
                owner.sendPageView()
            }
            .store(in: &cancellables)

        input.didSelect
            .withUnretained(self)
            .sink { owner, indexPath in
                let item = owner.output.sections.value[safe: indexPath.section]?.items[safe: indexPath.item]
                if case .popularStore(let store) = item {
                    switch store.type {
                    case .userStore:
                        guard let storeId = Int(store.id) else { return }
                        owner.output.route.send(.storeDetail(storeId))
                    case .bossStore:
                        owner.output.route.send(.bossStoreDetail(store.id))
                    }
                    owner.sendClickStoreLog(store: store)
                }
            }
            .store(in: &cancellables)
    }

    private func reloadDataSource() {
        var sections: [CommunitySection] = []

        sections.append(.init(type: .pollList, items: [.poll(pollListCellViewModel)]))
        sections.append(.init(type: .banner, items: [.banner]))
        sections.append(.init(type: .popularStoreTab, items: [.popularStoreTab(storeTabCellViewModel)]))

        sections.append(.init(type: .popularStore, items: state.storeList.value.map {
            .popularStore($0)
        }))

        output.sections.send(sections)
    }

    /// 동네 인기 가게 탭
    private func bindPopularStoreTabCellViewModel() -> CommunityPopularStoreTabCellViewModel {
        let cellViewModel = CommunityPopularStoreTabCellViewModel(tab: state.currentStoreTab.value)

        cellViewModel.output.didTapDistrictButton
            .withUnretained(self)
            .handleEvents(receiveOutput: { (owner: CommunityViewModel, _) in
                owner.sendClickDistrictLog()
            })
            .map { owner, _ in
                return .popularStoreNeighborhoods(owner.bindPopularStoreNeighborhoodsViewModel())
            }
            .subscribe(output.route)
            .store(in: &cancellables)

        cellViewModel.output.currentTab
            .dropFirst()
            .removeDuplicates()
            .withUnretained(self)
            .sink { owner, tab in
                owner.state.currentStoreTab.send(tab)
                owner.state.reload.send()
                owner.sendClickPopularFilterLog(type: tab)
            }
            .store(in: &cancellables)

        output.updatePopularStores
            .subscribe(cellViewModel.input.reload)
            .store(in: &cancellables)

        return cellViewModel
    }

    /// 동네 인기 가게 - 동네 선택
    private func bindPopularStoreNeighborhoodsViewModel() -> CommunityPopularStoreNeighborhoodsViewModel {
        let viewModel = CommunityPopularStoreNeighborhoodsViewModel()

        viewModel.output.updatePopularStores
            .subscribe(output.updatePopularStores)
            .store(in: &cancellables)

        viewModel.output.updatePopularStores
            .subscribe(state.reload)
            .store(in: &cancellables)

        return viewModel
    }

    /// 투표 목록
    private func bindPollListCellViewModel() -> CommunityPollListCellViewModel {
        let config = CommunityPollListCellViewModel.Config(screenName: output.screenName)
        let cellViewModel = CommunityPollListCellViewModel(config: config)
        
        input.viewWillAppear
            .subscribe(cellViewModel.input.loadPollList)
            .store(in: &cancellables)

        cellViewModel.output.didSelectCategory
            .withUnretained(self)
            .handleEvents(receiveOutput: { (owner: CommunityViewModel, _) in
                owner.sendClickPollCategoryLog()
            })
            .map { owner, category in 
                let viewModel = owner.bindPollCategoryTabViewModel(with: category)
                return .pollCategoryTab(viewModel) 
            }
            .subscribe(output.route)
            .store(in: &cancellables)

        cellViewModel.output.didSelectPollItem
            .handleEvents(receiveOutput: { [weak self] pollId in
                self?.sendClickPollLog(pollId: pollId)
            })
            .map { pollId in
                .pollDetail(PollDetailViewModel(pollId: pollId))
            }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        cellViewModel.output.showErrorAlert
            .subscribe(output.showErrorAlert)
            .store(in: &cancellables)

        return cellViewModel
    }

    /// 투표 카테고리 탭 목록
    private func bindPollCategoryTabViewModel(with category: PollCategoryResponse) -> PollCategoryTabViewModel {
        let config = PollCategoryTabViewModel.Config(
            categoryId: category.categoryId, 
            categoryName: category.title
        )
        let viewModel = PollCategoryTabViewModel(config: config)

        return viewModel
    }
}

// MARK: Log
extension CommunityViewModel {
    private func sendPageView() {
        logManager.sendPageView(screen: output.screenName, type: CommunityViewController.self)
    }
    
    private func sendClickPollLog(pollId: String) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickPoll,
            extraParameters: [ .pollId: pollId]
        ))
    }
    
    private func sendClickPollCategoryLog() {
        logManager.sendEvent(.init(screen: output.screenName, eventName: .clickPollCategory))
    }
    
    private func sendClickDistrictLog() {
        logManager.sendEvent(.init(screen: output.screenName, eventName: .clickDistrict))
    }
    
    private func sendClickPopularFilterLog(type: CommunityPopularStoreTab) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickPopularFilter,
            extraParameters: [
                .value: type.rawValue
            ]))
    }
    
    private func sendClickStoreLog(store: PlatformStore) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickStore,
            extraParameters: [
                .storeId: store.id,
                .type: store.type.rawValue
            ]))
    }
}
