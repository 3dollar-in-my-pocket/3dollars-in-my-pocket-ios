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
        let showErrorAlert = PassthroughSubject<Error, Never>()
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
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .asyncMap { owner, input in
                await owner.communityService.fetchPopularStoreNeighborhoods()
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                let selectedItem = owner.userDefaultsUtil.communityPopularStoreNeighborhoods.district
                switch result {
                case .success(let response):
                    var sectionItems = response.neighborhoods
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
                    #if DEBUG
                    if sectionItems.isNotEmpty {
                        sectionItems.insert(.district(CommunityNeighborhoods(
                            district: "GYEONGGI_GUNPO",
                            description: "군포(TEST)",
                            isSelected: "GYEONGGI_GUNPO" == selectedItem
                        )), at: 0)
                    }
                    #endif
                    owner.output.dataSource.send([
                        CommunityPopularStoreNeighborhoodsSection(
                            items: sectionItems
                        )
                    ])
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
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
}
