import Foundation
import Combine

import Common
import Model
import Networking
import Log

extension StorePreviewBottomSheetViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let didTapBody = PassthroughSubject<Void, Never>()
        let didTapTopActionBar = PassthroughSubject<Int, Never>()
        let didTapActionBar = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let section = PassthroughSubject<StorePreviewSection, Never>()
        let pageViewLog = PassthroughSubject<SDPageViewLog, Never>()
        let toast = PassthroughSubject<String, Never>()
        let isFavoriteOverride = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    enum Route {
        case pushStoreDetail(storeId: Int)
        case presentVisit(storeId: Int)
        case presentNavigation(latitude: Double, longitude: Double, storeName: String)
        case close
    }

    struct Config {
        let storeId: Int
        let latitude: Double
        let longitude: Double
    }

    struct Dependency {
        let storeRepository: StoreRepository
        let logManager: LogManagerProtocol

        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.storeRepository = storeRepository
            self.logManager = logManager
        }
    }

    struct State {
        var section: StorePreviewSection?
        var storeName: String = ""
        var isLoading: Bool = false
    }
}

final class StorePreviewBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state: State
    private let config: Config
    private let dependency: Dependency

    init(config: Config, dependency: Dependency = Dependency()) {
        self.config = config
        self.dependency = dependency
        self.state = State()
        super.init()
    }

    var storeId: Int { config.storeId }

    override func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: StorePreviewBottomSheetViewModel, _) in
                Task { [weak owner] in
                    await owner?.fetchPreview()
                }
            }
            .store(in: &cancellables)

        input.didTapBody
            .withUnretained(self)
            .sink { (owner: StorePreviewBottomSheetViewModel, _) in
                owner.output.route.send(.pushStoreDetail(storeId: owner.config.storeId))
            }
            .store(in: &cancellables)

        input.didTapTopActionBar
            .withUnretained(self)
            .sink { (owner: StorePreviewBottomSheetViewModel, index: Int) in
                guard let bar = owner.state.section?.topActionBars[safe: index] else { return }
                owner.handleActionBar(bar)
            }
            .store(in: &cancellables)

        input.didTapActionBar
            .withUnretained(self)
            .sink { (owner: StorePreviewBottomSheetViewModel, index: Int) in
                guard let bar = owner.state.section?.actionBars[safe: index] else { return }
                owner.handleActionBar(bar)
            }
            .store(in: &cancellables)
    }

    private func fetchPreview() async {
        guard !state.isLoading else { return }
        state.isLoading = true
        defer { state.isLoading = false }

        let input = FetchStoreScreenInput(
            storeId: String(config.storeId),
            latitude: config.latitude,
            longitude: config.longitude
        )
        let result = await dependency.storeRepository.fetchStoreScreenV2(input: input)

        switch result {
        case .success(let response):
            guard let preview = response.sections.compactMap({ $0 as? StorePreviewSection }).first else { return }
            state.section = preview
            state.storeName = preview.header.title?.text ?? ""
            output.section.send(preview)
            output.pageViewLog.send(response.viewLog)
        case .failure:
            break
        }
    }

    private func handleActionBar(_ bar: StorePreviewActionBar) {
        dependency.logManager.sendEvent(event: ClickEvent(clickLog: bar.clickLog))

        if let actionType = bar.button.customAction?.actionType {
            switch actionType {
            case .storePreviewFavorite:
                Task { [weak self] in
                    await self?.toggleFavorite(isDelete: false)
                }
            case .storePreviewUnfavorite:
                Task { [weak self] in
                    await self?.toggleFavorite(isDelete: true)
                }
            case .storePreviewClose:
                output.route.send(.close)
            case .storePreviewNavigation:
                output.route.send(.presentNavigation(
                    latitude: config.latitude,
                    longitude: config.longitude,
                    storeName: state.storeName
                ))
            case .storePreviewShare, .storePreviewReviewWrite:
                output.route.send(.pushStoreDetail(storeId: config.storeId))
            case .unknown:
                output.route.send(.pushStoreDetail(storeId: config.storeId))
            }
            return
        }

        if bar.button.link != nil {
            output.route.send(.pushStoreDetail(storeId: config.storeId))
            return
        }

        if let text = bar.button.text?.text, text.contains("방문") {
            output.route.send(.presentVisit(storeId: config.storeId))
            return
        }

        output.route.send(.pushStoreDetail(storeId: config.storeId))
    }

    private func toggleFavorite(isDelete: Bool) async {
        let result = await dependency.storeRepository.saveStore(
            storeId: String(config.storeId),
            isDelete: isDelete
        )
        switch result {
        case .success:
            output.isFavoriteOverride.send(isDelete.isNot)
            let message = isDelete
                ? "가게 저장이 취소되었어요"
                : "가게가 저장되었어요"
            output.toast.send(message)
        case .failure:
            break
        }
    }
}
