import Combine

import Common
import Model
import Networking
import Log

final class CommunityPollListAdCellViewModel: BaseViewModel {
    struct Input {
        
    }

    struct Output {
        let item: AdvertisementResponse?
    }

    struct State {
        
    }
    
    struct Config {
        let ad: AdvertisementResponse?
    }

    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output
    let config: Config

    private var state = State()
    private let communityRepository: CommunityRepository
    private let logManager: LogManagerProtocol

    init(
        config: Config,
        communityRepository: CommunityRepository = CommunityRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
        self.communityRepository = communityRepository
        self.logManager = logManager
        self.output = Output(item: config.ad)

        super.init()
    }

    override func bind() {
        super.bind()

    
    }
}

extension CommunityPollListAdCellViewModel: Hashable {
    static func == (lhs: CommunityPollListAdCellViewModel, rhs: CommunityPollListAdCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
