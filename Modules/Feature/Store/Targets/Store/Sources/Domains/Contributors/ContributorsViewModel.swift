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
        let loadMore = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let screenName: ScreenName = .storeContributors
        let items = PassthroughSubject<[SDUItem], Never>()
        let route = PassthroughSubject<Route, Never>()
        let error = PassthroughSubject<Error, Never>()
    }

    enum Route {
        case dismiss
        case pushEditStore(EditStoreViewModelInterface)
    }

    public struct Config {
        public let storeId: Int
        public let store: UserStoreResponse?

        public init(storeId: Int, store: UserStoreResponse?) {
            self.storeId = storeId
            self.store = store
        }
    }

    struct State {
        var cursor: String?
        var isLoading: Bool = false
    }

    public struct Dependency {
        let storeRepository: StoreRepository
        let logManager: LogManagerProtocol
        let writeInterface: WriteInterface

        public init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            writeInterface: WriteInterface = DIContainer.shared.container.resolve(WriteInterface.self)!
        ) {
            self.storeRepository = storeRepository
            self.logManager = logManager
            self.writeInterface = writeInterface
        }
    }
}

public final class ContributorsViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state: State
    private let config: Config
    private let dependency: Dependency

    public init(config: Config, dependency: Dependency = Dependency()) {
        self.config = config
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
                owner.pushEditStore()
            }
            .store(in: &cancellables)

        input.loadMore
            .withUnretained(self)
            .sink { (owner, _) in
                Task { [weak owner] in
                    await owner?.fetchHistories()
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func fetchHistories() async {
        guard !state.isLoading else { return }
        state.isLoading = true

        let result = await dependency.storeRepository.fetchStoreContributorHistories(
            storeId: config.storeId,
            cursor: state.cursor
        )

        state.isLoading = false

        switch result {
        case .success(let response):
            state.cursor = response.data.cursor.nextCursor
            let items = processCards(response.data.cards)
            output.items.send(items)

        case .failure(let error):
            output.error.send(error)
        }
    }

    private func processCards(_ cards: [StoreContributorCard]) -> [SDUItem] {
        return cards.compactMap { card in
            switch card.data {
            case .callout(let data):
                return .callout(data)
            case .iconText(let data):
                return .iconText(data)
            }
        }
    }

    private func pushEditStore() {
        guard let store = config.store else { return }

        let viewModelConfig = EditStoreViewModelConfig(store: store)
        let viewModel = dependency.writeInterface.createEditStoreViewModel(config: viewModelConfig)
        output.route.send(.pushEditStore(viewModel))
    }
}
