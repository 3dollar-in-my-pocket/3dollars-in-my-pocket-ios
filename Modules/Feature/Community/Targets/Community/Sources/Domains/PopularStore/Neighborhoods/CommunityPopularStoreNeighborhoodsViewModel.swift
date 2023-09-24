import Foundation
import Combine

import Networking
import Model
import Common

final class CommunityPopularStoreNeighborhoodsViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
        let didSelectItem = PassthroughSubject<CommunityNeighborhoods, Never>()
    }

    struct Output {
        let showLoading = PassthroughSubject<Bool, Never>()
        let dataSource = PassthroughSubject<[CommunityPopularStoreNeighborhoodsSection], Never>()
        let updatePopularStores = PassthroughSubject<Void, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    struct State {

    }

    enum Route {
        case back
    }

    let input = Input()
    let output = Output()

    private var state = State()

    private let communityService: CommunityServiceProtocol
    private let userDefaultsUtil: UserDefaultsUtil

    init(
        communityService: CommunityServiceProtocol = CommunityService(),
        userDefaultsUtil: UserDefaultsUtil = .shared
    ) {
        self.communityService = communityService
        self.userDefaultsUtil = userDefaultsUtil

        super.init()
    }

    override func bind() {
        super.bind()

        input.firstLoad
            .withUnretained(self)
            .sink { owner, _ in
                owner.fetchPopularStores()
            }
            .store(in: &cancellables)

        input.didSelectItem
            .withUnretained(self)
            .sink { owner, item in
                owner.userDefaultsUtil.communityPopularStoreNeighborhoods = item
                owner.output.updatePopularStores.send()
                owner.output.route.send(.back)
            }
            .store(in: &cancellables)
    }

    private func fetchPopularStores() {
        Task { [weak self] in
            guard let self else { return }

            let apiResult = await communityService.fetchPopularStoreNeighborhoods()
            let selectedItem = userDefaultsUtil.communityPopularStoreNeighborhoods.district

            switch apiResult {
            case .success(let response):
                let sectionItems = response.neighborhoods
                    .filter { $0.province == "SEOUL" }
                    .flatMap { $0.districts }
                    .map {
                        CommunityPopularStoreNeighborhoodsSectionItem.district(
                            CommunityNeighborhoods(
                                district: $0.district,
                                description: $0.description,
                                isSelected: $0.district == selectedItem
                            )
                        )
                    }
                output.dataSource.send([
                    CommunityPopularStoreNeighborhoodsSection(
                        items: sectionItems
                    )
                ])
            case .failure(let failure):
                print("💜error: \(failure)")
            }
        }
    }
}
