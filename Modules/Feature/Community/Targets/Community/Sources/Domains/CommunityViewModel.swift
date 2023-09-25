import Foundation
import Combine

import Networking
import Model
import Common

final class CommunityViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let didTapPollCategoryButton = PassthroughSubject<Void, Never>()
        let didSelectPollItem = PassthroughSubject<String, Never>()
        let didTapDistrictButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
        let sections = PassthroughSubject<[CommunitySection], Never>()
        let updatePopularStores = PassthroughSubject<Void, Never>()
    }

    struct State {

    }

    enum Route {
        case pollCategoryTab
        case pollDetail(PollDetailViewModel)
        case popularStoreNeighborhoods(CommunityPopularStoreNeighborhoodsViewModel)
    }

    let input = Input()
    let output = Output()

    private var state = State()

    private let communityService: CommunityServiceProtocol

    init(
        communityService: CommunityServiceProtocol = CommunityService()
    ) {
        self.communityService = communityService

        super.init()
    }

    override func bind() {
        super.bind()

        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: CommunityViewModel, _: Void) in
                owner.reloadDataSource()
            }
            .store(in: &cancellables)
    }

    private func reloadDataSource() {
        var sectionItems: [CommunitySectionItem] = []

        sectionItems.append(.poll(bindPollListCellViewModel()))
        sectionItems.append(.popularStore(bindPopularStoreTabCellViewModel()))

        output.sections.send([
            CommunitySection(items: sectionItems)
        ])
    }

    private func bindPopularStoreTabCellViewModel() -> CommunityPopularStoreTabCellViewModel {
        let cellViewModel = CommunityPopularStoreTabCellViewModel()

        cellViewModel.output.didTapDistrictButton
            .withUnretained(self)
            .map { owner, _ in
                return .popularStoreNeighborhoods(owner.bindPopularStoreNeighborhoodsViewModel())
            }
            .subscribe(output.route)
            .store(in: &cancellables)

        output.updatePopularStores
            .subscribe(cellViewModel.input.reload)
            .store(in: &cancellables)

        return cellViewModel
    }

    private func bindPopularStoreNeighborhoodsViewModel() -> CommunityPopularStoreNeighborhoodsViewModel {
        let viewModel = CommunityPopularStoreNeighborhoodsViewModel()

        viewModel.output.updatePopularStores
            .subscribe(output.updatePopularStores)
            .store(in: &cancellables)

        return viewModel
    }

    private func bindPollListCellViewModel() -> CommunityPollListCellViewModel {
        let cellViewModel = CommunityPollListCellViewModel()

        cellViewModel.output.didSelectCategory
            .map { _ in .pollCategoryTab }
            .subscribe(output.route)
            .store(in: &cancellables)

        cellViewModel.output.didSelectPollItem
            .map { pollId in
                .pollDetail(PollDetailViewModel(pollId: pollId))
            }
            .subscribe(output.route)
            .store(in: &cancellables)

        return cellViewModel
    }
}
