import Combine

import Common
import Model
import Networking
import Log

public enum ReviewTab {
    case store
    case bossStore
    
    var title: String {
        switch self {
        case .store: "유저 제보 가게"
        case .bossStore: "사장님 직영점"
        }
    }
    
    static var list: [ReviewTab] {
        return [.store, .bossStore]
    }
}

final class ReviewTabViewModel: BaseViewModel {
    struct Input {
        let firstLoad = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let changeTab = PassthroughSubject<Int, Never>()
    }
    
    struct State {
        
    }

    enum Route {
        case none
    }
    
    struct Config {
        
    }

    let input = Input()
    let output: Output

    private var state = State()
    
    private let config: Config
    private let communityService: CommunityServiceProtocol
    private let logManager: LogManagerProtocol

    init(
        config: Config,
        communityService: CommunityServiceProtocol = CommunityService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
        self.communityService = communityService
        self.logManager = logManager
        self.output = Output()

        super.init()
    }

    override func bind() {
        super.bind()
    }
}
