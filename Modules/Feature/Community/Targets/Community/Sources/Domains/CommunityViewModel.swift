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
    }

    struct State {

    }

    enum Route {
        case pollCategoryTab
        case pollDetail
        case popularStoreNeighborhoods
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
                owner.fetchPopularStores()
            }
            .store(in: &cancellables)

        input.didTapPollCategoryButton
            .map { _ in .pollCategoryTab }
            .subscribe(output.route)
            .store(in: &cancellables)

        input.didSelectPollItem
            .map { _ in .pollDetail }
            .subscribe(output.route)
            .store(in: &cancellables)

        input.didTapDistrictButton
            .map { _ in .popularStoreNeighborhoods }
            .subscribe(output.route)
            .store(in: &cancellables)
    }

    private func fetchPopularStores() {
        Task { [weak self] in
            guard let self else { return }

            let input = FetchPopularStoresInput(criteria: "MOST_REVIEWS", district: "GYEONGGI_GUNPO")

            let storeDetailResult = await communityService.fetchPopularStores(input: input)

            switch storeDetailResult {
            case .success(let response):
                let storeList = response.contents.map {
                    PlatformStore(response: $0)
                }
                let cellViewModel = CommunityPopularStoreTabCellViewModel(storeList: storeList)
                output.sections.send([
                    .init(items: [
                        .poll,
                        .popularStore(cellViewModel)
                    ])
                ])
            case .failure(let failure):
                print("💜error: \(failure)")
            }
        }
    }
}
