import Combine

import Common
import Model
import Networking
import Log

final class MyPageOverviewCellViewModel: BaseViewModel {
    struct Input {
        let didTapStoreCountButton = PassthroughSubject<Void, Never>()
        let didTapReviewButton = PassthroughSubject<Void, Never>()
        let didTapMedalImageButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let screenName: ScreenName
        let item: UserDetailResponse
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case store
        case review
        case medal
    }
    
    struct Config {
        let item: UserDetailResponse
        let screenName: ScreenName
    }
    
    lazy var identifier = ObjectIdentifier(self)

    let input = Input()
    let output: Output
    
    private let logManager: LogManagerProtocol

    init(config: Config, logManager: LogManagerProtocol = LogManager.shared) {
        self.output = Output(screenName: config.screenName, item: config.item)
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapStoreCountButton
            .map { _ in .store }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.didTapReviewButton
            .map { _ in .review }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.didTapMedalImageButton
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.sendMedalClickLog()
            })
            .map { _ in .medal }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
}

// MARK: Log
private extension MyPageOverviewCellViewModel {
    func sendMedalClickLog() {
        logManager.sendEvent(.init(screen: output.screenName, eventName: .clickMedal))
    }
}

extension MyPageOverviewCellViewModel: Hashable {
    static func == (lhs: MyPageOverviewCellViewModel, rhs: MyPageOverviewCellViewModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
