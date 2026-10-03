import Combine
import Foundation

import Common
import Model
import Networking

extension MenuExtractionLoadingViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let didTapClose = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let afterCreatedStore: Bool
        let finishExtraction = PassthroughSubject<MenuExtractionResult, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    enum Route {
        case replaceWithResult(MenuExtractionResultViewModel)
        case showErrorAlert(Error)
        case close
    }

    struct Config {
        let image: Data
        let afterCreatedStore: Bool
        let menuExtractionUsage: MenuExtractionUsage
    }

    struct Dependency {
        let storeMenuExtractionRepository: StoreMenuExtractionRepository

        init(storeMenuExtractionRepository: StoreMenuExtractionRepository = StoreMenuExtractionRepositoryImpl()) {
            self.storeMenuExtractionRepository = storeMenuExtractionRepository
        }
    }

    struct State {
        var extractionTask: Task<Void, Never>?
    }
}

final class MenuExtractionLoadingViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private let config: Config
    private let dependency: Dependency
    private var state = State()

    init(config: Config, dependency: Dependency = Dependency()) {
        self.config = config
        self.output = Output(afterCreatedStore: config.afterCreatedStore)
        self.dependency = dependency
        super.init()
    }

    override func bind() {
        input.viewDidLoad
            .sink { [weak self] in
                self?.extractMenus()
            }
            .store(in: &cancellables)

        input.didTapClose
            .sink { [weak self] in
                self?.state.extractionTask?.cancel()
                self?.output.route.send(.close)
            }
            .store(in: &cancellables)
    }

    private func extractMenus() {
        state.extractionTask?.cancel()
        state.extractionTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let result = await dependency.storeMenuExtractionRepository.extractStoreMenus(image: config.image)
            guard Task.isCancelled.isNot else { return }

            switch result {
            case .success(let response):
                handleExtraction(response)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }

    private func handleExtraction(_ response: StoreMenuExtractionListResponse) {
        let extractionResult = MenuExtractionResult(response: response)
        guard extractionResult.menus.isNotEmpty else {
            output.route.send(.showErrorAlert(NetworkError.message(Strings.MenuExtractionLoading.empty)))
            return
        }

        self.config.menuExtractionUsage.markUsed()
        let config = MenuExtractionResultViewModel.Config(
            result: extractionResult,
            afterCreatedStore: config.afterCreatedStore
        )
        let viewModel = MenuExtractionResultViewModel(config: config)
        viewModel.output.finishRegister
            .subscribe(output.finishExtraction)
            .store(in: &viewModel.cancellables)

        output.route.send(.replaceWithResult(viewModel))
    }
}
