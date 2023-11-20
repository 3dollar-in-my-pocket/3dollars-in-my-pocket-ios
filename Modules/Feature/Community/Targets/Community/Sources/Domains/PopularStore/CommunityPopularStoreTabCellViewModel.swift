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
        let currentTab: CurrentValueSubject<CommunityPopularStoreTab, Never>
        let didTapDistrictButton = PassthroughSubject<Void, Never>()
    }

    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output

    private let communityService: CommunityServiceProtocol
    private let userDefaultsUtil: UserDefaultsUtil

    init(
        tab: CommunityPopularStoreTab = .defaultTab,
        communityService: CommunityServiceProtocol = CommunityService(),
        userDefaultsUtil: UserDefaultsUtil = .shared
    ) {
        self.communityService = communityService
        self.userDefaultsUtil = userDefaultsUtil
        self.output = Output(
            tabList: CommunityPopularStoreTab.allCases,
            district: .init(userDefaultsUtil.communityPopularStoreNeighborhoods.description),
            currentTab: .init(tab)
        )

        super.init()
    }

    override func bind() {
        super.bind()

        input.didSelectTab
            .withUnretained(self)
            .sink { (owner: CommunityPopularStoreTabCellViewModel, index: Int) in
                owner.output.currentTab.send(owner.output.tabList[safe: index] ?? .defaultTab)
            }
            .store(in: &cancellables)

        input.didTapDistrictButton
            .subscribe(output.didTapDistrictButton)
            .store(in: &cancellables)

        input.reload
            .withUnretained(self)
            .sink { (owner: CommunityPopularStoreTabCellViewModel, _) in
                owner.output.district.send(owner.userDefaultsUtil.communityPopularStoreNeighborhoods.description)
            }
            .store(in: &cancellables)
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
