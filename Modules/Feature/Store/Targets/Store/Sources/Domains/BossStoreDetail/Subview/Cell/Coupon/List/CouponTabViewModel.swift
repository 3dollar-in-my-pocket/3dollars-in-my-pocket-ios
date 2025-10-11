import Combine

import Common
import Model
import Networking
import Log

public enum CouponTab {
    case active
    case nonActive
    
    var title: String {
        switch self {
        case .active: "사용 가능 쿠폰"
        case .nonActive: "지난 쿠폰"
        }
    }
    
    static var list: [CouponTab] {
        return [.active, .nonActive]
    }
}

final class CouponTabViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let screenName: ScreenName = .myReview
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let changeTab = PassthroughSubject<Int, Never>()
        let onReload = PassthroughSubject<Void, Never>()
        let activeCouponListViewModel = CouponListViewModel(config: .init(statuses: [.issued]))
        let nonActiveCouponListViewModel = CouponListViewModel(config: .init(statuses: [.used, .expired]))
    }
    
    enum Route {
        case none
    }
    
    let input = Input()
    let output: Output

    private let communityRepository: CommunityRepository
    private let logManager: LogManagerProtocol

    init(
        communityRepository: CommunityRepository = CommunityRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.communityRepository = communityRepository
        self.logManager = logManager
        self.output = Output()

        super.init()
    }

    override func bind() {
        super.bind()
        
        output.activeCouponListViewModel.output.reload
            .subscribe(output.onReload)
            .store(in: &output.activeCouponListViewModel.cancellables)
    }
}
