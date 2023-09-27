import Combine

import Common
import Model
import Networking

extension CommunityPopularStoreTab {
    var title: String {
        switch self {
        case .mostReviews: return "리뷰가 많아요"
        case .mostVisits: return "많이 갔다왔어요"
        }
    }

    static var defaultTab: CommunityPopularStoreTab {
        return .mostReviews
    }
}

final class CommunityPopularStoreTabCellViewModel: BaseViewModel {
    struct Input {
        let reload = PassthroughSubject<Void, Never>()
        let didSelectTab = PassthroughSubject<Int, Never>()
        let didTapDistrictButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let tabList: [CommunityPopularStoreTab]
        let district: CurrentValueSubject<String, Never>
        let storeList = CurrentValueSubject<[PlatformStore], Never>([])
        let didTapDistrictButton = PassthroughSubject<Void, Never>()
    }

    struct State {
        var currentTab: CommunityPopularStoreTab = .defaultTab
    }

    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output

    private var state = State()

    private let communityService: CommunityServiceProtocol
    private let userDefaultsUtil: UserDefaultsUtil

    init(
        communityService: CommunityServiceProtocol = CommunityService(),
        userDefaultsUtil: UserDefaultsUtil = .shared
    ) {
        self.communityService = communityService
        self.userDefaultsUtil = userDefaultsUtil
        self.output = Output(
            tabList: CommunityPopularStoreTab.allCases,
            district: .init(userDefaultsUtil.communityPopularStoreNeighborhoods.description)
        )

        super.init()

        fetchPopularStores()
    }

    override func bind() {
        super.bind()

        input.didSelectTab
            .withUnretained(self)
            .sink { (owner: CommunityPopularStoreTabCellViewModel, index: Int) in
                owner.state.currentTab = owner.output.tabList[safe: index] ?? .defaultTab
                owner.fetchPopularStores()
            }
            .store(in: &cancellables)

        input.didTapDistrictButton
            .subscribe(output.didTapDistrictButton)
            .store(in: &cancellables)

        input.reload
            .withUnretained(self)
            .sink { (owner: CommunityPopularStoreTabCellViewModel, _) in
                owner.output.district.send(owner.userDefaultsUtil.communityPopularStoreNeighborhoods.description)
                owner.fetchPopularStores()
            }
            .store(in: &cancellables)
    }

    private func fetchPopularStores() {
        Task { [weak self] in
            guard let self else { return }

            let input = FetchPopularStoresInput(
                criteria: state.currentTab.rawValue,
                district: "GYEONGGI_GUNPO" // userDefaultsUtil.communityPopularStoreNeighborhoods.district
            )

            let storeDetailResult = await communityService.fetchPopularStores(input: input)

            switch storeDetailResult {
            case .success(let response):
                let storeList = response.contents.map {
                    PlatformStore(response: $0)
                }
                output.storeList.send(storeList)
            case .failure(let failure):
                print("💜error: \(failure)")
            }
        }
    }
}

extension CommunityPopularStoreTabCellViewModel: Hashable {
    static func == (lhs: CommunityPopularStoreTabCellViewModel, rhs: CommunityPopularStoreTabCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
