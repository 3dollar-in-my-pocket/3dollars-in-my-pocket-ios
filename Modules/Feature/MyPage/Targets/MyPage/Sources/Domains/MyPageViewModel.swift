import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class MyPageViewModel: BaseViewModel {
    struct Input {
        let loadTrigger = PassthroughSubject<Void, Never>()
        let reloadTrigger = PassthroughSubject<Void, Never>()
        let didSelect = PassthroughSubject<MyPageSectionItem, Never>()
    }

    struct Output {
        let screenName: ScreenName = .myPage
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let sections = CurrentValueSubject<[MyPageSection], Never>([])
    }

    struct State {
        let userState = CurrentValueSubject<UserWithDetailApiResponse?, Never>(nil)
        let visitStores = CurrentValueSubject<[MyPageStore], Never>([])
        let favoriteStores = CurrentValueSubject<[MyPageStore], Never>([])
        let poll = CurrentValueSubject<PollListWithUserPollMetaApiResponse?, Never>(nil)
    }

    enum Route {
        case registeredStoreList
        case review(ReviewTabViewModel)
        case visitStore(VisitStoreListViewModel)
        case favoriteStore
        case medal(MyMedalViewModel)
        case storeDetail(Int)
        case bossStoreDetail(String)
        case pollDetail(String)
    }

    let input = Input()
    let output = Output()

    private var state = State()

    private let myPageService: MyPageServiceProtocol
    private let communityService: CommunityServiceProtocol
    
    private let preference = Preference.shared
    private let logManager: LogManagerProtocol
    
    private lazy var visitStoreHeaderViewModel = bindHeaderViewModel(.visitStore)
    private lazy var favoriteStoreHeaderViewModel = bindHeaderViewModel(.favoriteStore)
    private lazy var pollHeaderViewModel = bindHeaderViewModel(.poll)

    init(
        myPageService: MyPageServiceProtocol = MyPageService(),
        communityService: CommunityServiceProtocol = CommunityService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.myPageService = myPageService
        self.communityService = communityService
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()
        
        let loadTrigger = input.loadTrigger
            .merge(with: input.reloadTrigger)
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .withUnretained(self)
            .share()
        
        let fetchMyUser = loadTrigger
            .asyncMap { owner, _ in
                await owner.myPageService.fetchMyUser()
            }.compactMapValue()
        
        let fetchVisitStore = loadTrigger
            .asyncMap { owner, _ in
                await owner.myPageService.fetchMyStoreVisits(
                    size: 20, // TODO
                    cursur: nil
                )
            }.compactMapValue()
        
        let fetchFavoriteStores = loadTrigger
            .asyncMap { owner, _ in
                await owner.myPageService.fetchMyFavoriteStores(
                    size: 20, // TODO
                    cursur: nil
                )
            }.compactMapValue()
        
        let fetchMyPolls = loadTrigger
            .asyncMap { owner, _ in
                await owner.communityService.fetchMyPolls(
                    input: .init(size: 3) // TODO
                )
            }.compactMapValue()
        
        Publishers.Zip4(fetchMyUser, fetchVisitStore, fetchFavoriteStores, fetchMyPolls)
            .sink { [weak self] user, visitStore, favoriteStores, myPolls in
                guard let self else { return } 
                
                output.showLoading.send(false)
                
                state.userState.send(user)
                state.visitStores.send(visitStore.contents.map {
                    MyPageStore(storeResponse: $0.store, visitResponse: $0.visit) 
                })
                state.favoriteStores.send(favoriteStores.favorites.map { 
                    MyPageStore(storeResponse: $0) 
                })
                state.poll.send(myPolls)
                
                visitStoreHeaderViewModel.input.count.send(user.activities?.visitStoreCount)
                favoriteStoreHeaderViewModel.input.count.send(user.activities?.favoriteStoreCount)
                
                updateDataSource()
            }
            .store(in: &cancellables)
        
        input.didSelect
            .sink { [weak self] in
                switch $0 {
                case let .poll(data, _, _):
                    self?.sendClickPoll(data)
                    self?.output.route.send(.pollDetail(data.pollId))
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func updateDataSource() {
        var sections: [MyPageSection] = []
        
        if let user = state.userState.value {
            sections.append(
                MyPageSection(
                    type: .overview, 
                    items: [.overview(bindMyPageOverviewCellViewModel(with: user))],
                    headerViewModel: nil
                )
            )
        }
        
        // 방문한 가게
        let visitStores = state.visitStores.value
        let visitStoreSectionItems: MyPageSectionItem = 
            if visitStores.isEmpty {
                .empty(.visitStore)
            } else {
                .visitStore(bindStoreListCellViewModel(with: visitStores, sectionType: .visit))
            }
        
        sections.append(
            MyPageSection(
                type: .visitStore, 
                items: [visitStoreSectionItems],
                headerViewModel: visitStoreHeaderViewModel
            )
        )
        
        // 좋아하는 가게
        let favoriteStores = state.favoriteStores.value
        let favoriteStoresSectionItems: MyPageSectionItem = 
            if favoriteStores.isEmpty {
                .empty(.favoriteStore)
            } else {
                .favoriteStore(bindStoreListCellViewModel(with: favoriteStores, sectionType: .favorite))
            }
        sections.append(
            MyPageSection(
                type: .favoriteStore, 
                items: [favoriteStoresSectionItems],
                headerViewModel: favoriteStoreHeaderViewModel
            )
        )
        
        // 투표의 히스토리
        var pollSectionItems: [MyPageSectionItem] = []
        if let poll = state.poll.value, poll.polls.contents.count > 0 {
            pollSectionItems.append(.pollTotalParticipantsCount(poll.meta.totalParticipantsCount))
            pollSectionItems.append(
                contentsOf: poll.polls.contents.map { 
                    .poll(
                        data: $0.poll, 
                        isFirst: poll.polls.contents.first?.poll.pollId == $0.poll.pollId, 
                        isLast: poll.polls.contents.last?.poll.pollId == $0.poll.pollId
                    )
                }
            )
        } else {
            pollSectionItems.append(.empty(.poll))
        }
        sections.append(
            MyPageSection(
                type: .poll, 
                items: pollSectionItems, 
                headerViewModel: pollHeaderViewModel
            )
        )
        
        output.sections.send(sections)
    }
    
    private func bindHeaderViewModel(_ type: MyPageSectionType) -> MyPageSectionHeaderViewModel {
        let viewModel = MyPageSectionHeaderViewModel(item: type)
        viewModel.output.didTapCountButton
            .compactMap {
                switch $0 {
                case .visitStore: .visitStore(VisitStoreListViewModel())
                case .favoriteStore: .favoriteStore // TODO
                default: nil
                }
            }
            .subscribe(output.route)
            .store(in: &cancellables)
        return viewModel
    }
    
    private func bindMyPageOverviewCellViewModel(with item: UserWithDetailApiResponse) -> MyPageOverviewCellViewModel {
        let config = MyPageOverviewCellViewModel.Config(item: item, screenName: output.screenName)
        let viewModel = MyPageOverviewCellViewModel(config: config)
        viewModel.output.route
            .compactMap {
                switch $0 {
                case .review: 
                    return .review(ReviewTabViewModel(config: .init()))
                case .store:
                    return .registeredStoreList
                case .medal:
                    let viewModel = MyMedalViewModel()
                    return .medal(viewModel)
                }
            }
            .subscribe(output.route)
            .store(in: &cancellables)
        return viewModel
    }
    
    private func bindStoreListCellViewModel(
        with items: [MyPageStore],
        sectionType: MyPageStoreListCellViewModel.SectionType
    ) -> MyPageStoreListCellViewModel {
        let config = MyPageStoreListCellViewModel.Config(
            screenName: output.screenName,
            sectionType: sectionType,
            items: items
        )
        let viewModel = MyPageStoreListCellViewModel(config: config)
        viewModel.output.route
            .compactMap {
                switch $0 {
                case .storeDetail(let storeId): 
                    return .storeDetail(storeId)
                case .bossStoreDetail(let storeId):
                    return .bossStoreDetail(storeId)
                }
            }
            .subscribe(output.route)
            .store(in: &cancellables)
        return viewModel
    }
}

// MARK: - Log
private extension MyPageViewModel {
    func sendClickPoll(_ poll: PollApiResponse) {
        logManager.sendEvent(.init(screen: output.screenName, eventName: .clickMyPoll, extraParameters: [.pollId: poll.pollId]))
    }
}
