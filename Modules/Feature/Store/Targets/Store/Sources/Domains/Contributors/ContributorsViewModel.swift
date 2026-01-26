import Foundation
import Combine

import Common
import DependencyInjection
import Log
import Model
import Networking
import SDU
import WriteInterface

extension ContributorsViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let didTapClose = PassthroughSubject<Void, Never>()
        let didTapEdit = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let screenName: ScreenName = .storeContributors
        let storeId: Int
        let items = PassthroughSubject<[SDUItem], Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    struct State {
        var cursor: String?
        var isLoading: Bool = false
        var items: [StoreContributorCard] = []
    }

    enum Route {
        case dismiss
        case dismissAndEdit
        case showErrorAlert(Error)
    }

    public struct Config {
        public let storeId: Int
        public let onEditRequested: () -> Void

        public init(storeId: Int, onEditRequested: @escaping () -> Void) {
            self.storeId = storeId
            self.onEditRequested = onEditRequested
        }
    }

    public struct Dependency {
        let storeRepository: StoreRepository
        let logManager: LogManagerProtocol

        public init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.storeRepository = storeRepository
            self.logManager = logManager
        }
    }
}

public final class ContributorsViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    private let dependency: Dependency
    let onEditRequested: () -> Void

    public init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(storeId: config.storeId)
        self.onEditRequested = config.onEditRequested
        self.dependency = dependency
        self.state = State()
    }

    public override func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner, _) in
                Task { [weak owner] in
                    await owner?.fetchHistories()
                }
            }
            .store(in: &cancellables)

        input.didTapClose
            .map { Route.dismiss }
            .subscribe(output.route)
            .store(in: &cancellables)

        input.didTapEdit
            .withUnretained(self)
            .sink { (owner, _) in
                owner.sendClickEditButtonLog()
                owner.dissmissAndPushEdit()
            }
            .store(in: &cancellables)
        
        input.willDisplayCell
            .sink { [weak self] index in
                guard
                    let self,
                    canLoadMore(index: index)
                else {
                    return
                }
                
                Task { [weak self] in
                    await self?.fetchHistories()
                }
            }
            .store(in: &cancellables)
    }

    private func fetchHistories() async {
        guard state.isLoading.isNot else { return }
        state.isLoading = true

        let result = await dependency.storeRepository.fetchStoreContributorHistories(
            storeId: output.storeId,
            cursor: state.cursor
        )

        state.isLoading = false

        switch result {
        case .success(let response):
            state.cursor = response.cursor.nextCursor
            state.items.append(contentsOf: response.cards)
            updateDatasource()
        case .failure(let error):
            output.route.send(.showErrorAlert(error))
        }
    }

    private func updateDatasource() {
        let sduItems: [SDUItem] = state.items.compactMap { card in
            switch card.data {
            case .callout(let data):
                let config = SDUCalloutCellViewModel.Config(data: data)
                let viewModel = SDUCalloutCellViewModel(config: config)
                return .callout(viewModel)

            case .iconText(let data):
                let config = SDUIconTextCardCellViewModel.Config(data: data)
                let viewModel = SDUIconTextCardCellViewModel(config: config)
                return .iconText(viewModel)
            }
        }

        output.items.send(sduItems)
    }

    private func dissmissAndPushEdit() {
        output.route.send(.dismissAndEdit)
    }
    
    private func canLoadMore(index: Int) -> Bool {
        return state.cursor.isNotNil && state.items.count - 1 <= index
    }
}

// MARK: Log
extension ContributorsViewModel {
    private func sendClickEditButtonLog() {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .edit
        ))
    }
}
