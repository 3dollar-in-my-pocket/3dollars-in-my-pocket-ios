import Foundation
import Combine

import Common
import Model
import Log

extension HomeListViewModel {
    struct Input {
        let updateCards = PassthroughSubject<[any HomeListCardComponent], Never>()
        let willDisplay = PassthroughSubject<Int, Never>()
        let didTapCard = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let screenName: ScreenName = .home
        let dataSource = CurrentValueSubject<[HomeListSection], Never>([])
        /// 부모(HomeViewModel) 가 fetchMore 를 트리거하도록 알린다.
        let willLoadMore = PassthroughSubject<Void, Never>()
        /// 부모(HomeViewModel) 가 카드 탭 라우팅을 처리하도록 인덱스 를 전달한다.
        let didTapCardAt = PassthroughSubject<Int, Never>()
    }

    struct State {
        var cards: [any HomeListCardComponent] = []
    }

    public struct Config {
        public init() { }
    }

    struct Dependency {
        let logManager: LogManagerProtocol

        init(logManager: LogManagerProtocol = LogManager.shared) {
            self.logManager = logManager
        }
    }
}

final class HomeListViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: Dependency

    init(config: Config = Config(), dependency: Dependency = Dependency()) {
        self.dependency = dependency
        super.init()
    }

    override func bind() {
        input.updateCards
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, cards: [any HomeListCardComponent]) in
                owner.state.cards = cards
                owner.emitDataSource()
            }
            .store(in: &cancellables)

        input.willDisplay
            .withUnretained(self)
            .sink { (owner: HomeListViewModel, index: Int) in
                owner.handleWillDisplay(at: index)
            }
            .store(in: &cancellables)

        input.didTapCard
            .subscribe(output.didTapCardAt)
            .store(in: &cancellables)
    }

    private func emitDataSource() {
        var items: [HomeListSectionItem] = []
        for card in state.cards {
            if let basic = card as? HomeListBasicCardResponse {
                items.append(.basicCard(basic))
            } else if let admob = card as? HomeListAdmobCardResponse {
                items.append(.admobCard(admob))
            } else if let empty = card as? HomeListEmptyCardResponse {
                items.append(.emptyCard(empty))
            }
        }
        output.dataSource.send([HomeListSection(items: items)])
    }

    private func handleWillDisplay(at index: Int) {
        guard let card = state.cards[safe: index] else { return }

        // willDisplay 시점마다 impression 로그를 발사한다 (1회 디듭 X).
        let log: SDImpressionLog?
        switch card {
        case let basic as HomeListBasicCardResponse:
            log = basic.impressionLog
        case let admob as HomeListAdmobCardResponse:
            log = admob.impressionLog
        case let empty as HomeListEmptyCardResponse:
            log = empty.impressionLog
        default:
            log = nil
        }
        if let log {
            dependency.logManager.sendEvent(event: ImpressionEvent(impressionLog: log))
        }

        // 마지막 셀이 보이면 부모에게 더 가져오라고 알린다.
        if index >= state.cards.count - 1 {
            output.willLoadMore.send(())
        }
    }
}
