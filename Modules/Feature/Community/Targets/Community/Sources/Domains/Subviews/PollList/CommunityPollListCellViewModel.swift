import Combine
import Foundation

import Common
import Model
import Networking
import Log

final class CommunityPollListCellViewModel: BaseViewModel {
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
        let didSelectCategory = PassthroughSubject<String, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    struct State {
        var category: PollCategoryResponse? 
    }
    
    struct Config {
        let screenName: ScreenName
    }

    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output
    let config: Config

    private var state = State()

    private let communityService: CommunityServiceProtocol

    init(
        config: Config,
        communityService: CommunityServiceProtocol = CommunityService()
    ) {
        self.config = config
        self.communityService = communityService
        self.output = Output()

        super.init()
        
        input.loadPollCategories.send()
    }

    override func bind() {
        super.bind()
        
        input.loadPollCategories
            .withUnretained(self)
            .asyncMap { owner, _ in
                await owner.communityService.fetchPollCategories()
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
            .compactMap { owner, _ in owner.state.category?.categoryId }
            .subscribe(output.didSelectCategory)
            .store(in: &cancellables)

        input.didSelectPollItem
            .withUnretained(self)
            .sink { owner, index in
                guard let sectionItem = owner.output.sections.value.first?.items[safe: index]  else { return }
                switch sectionItem {
                case .poll(let viewModel):
                    owner.output.didSelectPollItem.send(viewModel.pollId)
                }
            }
            .store(in: &cancellables)

        input.loadPollList
            .compactMap { [weak self] _ in self?.state.category?.categoryId }
            .withUnretained(self)
            .asyncMap { owner, categoryId in
                await owner.communityService.fetchPolls(
                    input: FetchPollsRequestInput(categoryId: categoryId, sortType: .popular) // 인기순 노출 고정
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success(let response):
                    owner.output.sections.send([.init(items: response.contents.map { 
                        .poll(owner.bindPollItemCellViewModel(with: $0))
                    })])
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
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
