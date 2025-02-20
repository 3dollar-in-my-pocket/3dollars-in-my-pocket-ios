import Combine
import Foundation

import Common
import Model
import Networking
import Log

final class CommunityPollListCellViewModel: BaseViewModel {
    enum Constant {
        static let advertisementIndex = 1
    }
    
    struct Input {
        let loadPollCategories = PassthroughSubject<Void, Never>()
        let loadPollList = PassthroughSubject<Void, Never>()
        
        // UI Event
        let didSelectPollItem = PassthroughSubject<Int, Never>()
        let didSelectCategory = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let title = CurrentValueSubject<String?, Never>(nil)
        let categoryName = CurrentValueSubject<String?, Never>(nil)
        let sections = CurrentValueSubject<[CommunityPollListCellSection], Never>([])
        let didSelectPollItem = PassthroughSubject<String, Never>()
        let didSelectCategory = PassthroughSubject<PollCategoryResponse, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case deepLink(AdvertisementResponse)
    }

    struct State {
        var category: PollCategoryResponse? 
        var pollList: [PollItemCellViewModel] = []
        var ad: AdvertisementResponse?
    }
    
    struct Config {
        let screenName: ScreenName
    }
    
    struct Dependency {
        let logManager: LogManagerProtocol
        
        init(logManager: LogManagerProtocol = LogManager.shared) {
            self.logManager = logManager
        }
    }

    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output = Output()
    let config: Config

    private var state = State()
    private let dependency: Dependency
    private let communityRepository: CommunityRepository
    private let advertisementRepository: AdvertisementRepository

    init(
        config: Config,
        dependency: Dependency = Dependency(),
        communityRepository: CommunityRepository = CommunityRepositoryImpl(),
        advertisementRepository: AdvertisementRepository = AdvertisementRepositoryImpl()
    ) {
        self.config = config
        self.dependency = dependency
        self.communityRepository = communityRepository
        self.advertisementRepository = advertisementRepository

        super.init()
        
        input.loadPollCategories.send()
    }

    override func bind() {
        super.bind()
        
        input.loadPollCategories
            .withUnretained(self)
            .asyncMap { owner, _ in
                await owner.communityRepository.fetchPollCategories()
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let repsonse):
                    // 현재는 다중 카테고리 선택이 고려되지 않았기에 하나의 카테고리만 무조건 노출합니다.
                    if let category = repsonse.categories.first {
                        owner.state.category = category
                        owner.output.title.send(category.content)
                        owner.output.categoryName.send(category.title)
                        owner.input.loadPollList.send()
                    }
                case .failure(let error):
                    // TODO: 에러 처리
                    break
                }
            }
            .store(in: &cancellables)

        input.didSelectCategory
            .withUnretained(self)
            .compactMap { owner, _ in owner.state.category }
            .subscribe(output.didSelectCategory)
            .store(in: &cancellables)

        input.didSelectPollItem
            .withUnretained(self)
            .sink { owner, index in
                guard let sectionItem = owner.output.sections.value.first?.items[safe: index]  else { return }
                switch sectionItem {
                case .poll(let viewModel):
                    owner.output.didSelectPollItem.send(viewModel.pollId)
                case .ad(let viewModel):
                    owner.sendClickAdvertisementLog()
                    owner.output.route.send(.deepLink(viewModel.output.item))
                }
            }
            .store(in: &cancellables)

        let load = input.loadPollList
            .compactMap { [weak self] _ in self?.state.category?.categoryId }
            .share()
        
        load
            .withUnretained(self)
            .asyncMap { owner, categoryId in
                await owner.communityRepository.fetchPolls(
                    input: FetchPollsRequestInput(categoryId: categoryId, sortType: .popular) // 인기순 노출 고정
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    owner.state.pollList = response.contents.map { 
                       owner.bindPollItemCellViewModel(with: $0)
                    }
                    owner.updateDataSource()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
        
        load
            .map { _ in FetchAdvertisementInput(position: .pollCard, size: nil) }
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.advertisementRepository.fetchAdvertisements(input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let advertisements):
                    guard let advertisement = advertisements.advertisements.first else { return }
                    owner.state.ad = advertisement
                    owner.updateDataSource()
                case .failure:
                    break
                }
            }
            .store(in: &cancellables)
        
    }
    
    private func updateDataSource() {
        var sectionItems: [CommunityPollListCellSectionItem] = []
       
        sectionItems.append(contentsOf: state.pollList.map { .poll($0) })
        if let ad = state.ad, sectionItems.isNotEmpty {
            let index = ad.metadata?.exposureIndex ?? Constant.advertisementIndex
            sectionItems.insert(.ad(CommunityPollListAdCellViewModel(config: .init(ad: ad))), at: index)
        }
        
        output.sections.send([.init(items: sectionItems)])
    }

    private func bindPollItemCellViewModel(with data: PollWithMetaApiResponse) -> PollItemCellViewModel {
        let config = PollItemCellViewModel.Config(screenName: config.screenName, data: data)
        let cellViewModel = PollItemCellViewModel(config: config)
        
        cellViewModel.output.showErrorAlert
            .subscribe(output.showErrorAlert)
            .store(in: &cellViewModel.cancellables)
        return cellViewModel
    }
}

extension CommunityPollListCellViewModel: Hashable {
    static func == (lhs: CommunityPollListCellViewModel, rhs: CommunityPollListCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

// MARK: Log
extension CommunityPollListCellViewModel {
    private func sendClickAdvertisementLog() {
        guard let advertisement = state.ad else { return }
        dependency.logManager.sendEvent(.init(
            screen: config.screenName,
            eventName: .clickAdCard,
            extraParameters: [.advertisementId: "\(advertisement.advertisementId)"])
        )
    }
}
