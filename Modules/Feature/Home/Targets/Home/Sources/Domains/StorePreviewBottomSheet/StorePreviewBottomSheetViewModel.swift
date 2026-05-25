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
        let didTapSave = PassthroughSubject<Void, Never>()
        let didTapClose = PassthroughSubject<Void, Never>()
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
        case presentReviewWrite(storeId: Int)
        case share(storeId: Int, storeType: StoreType, storeName: String, latitude: Double, longitude: Double)
        case presentNavigation(latitude: Double, longitude: Double, storeName: String)
        case openLink(SDLink)
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
        var isFavorited: Bool = false
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

        input.didTapSave
            .withUnretained(self)
            .sink { (owner: StorePreviewBottomSheetViewModel, _) in
                Task { [weak owner] in
                    await owner?.toggleFavorite()
                }
            }
            .store(in: &cancellables)

        input.didTapClose
            .withUnretained(self)
            .sink { (owner: StorePreviewBottomSheetViewModel, _) in
                owner.output.route.send(.close)
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

        if let customAction = bar.button.customAction {
            switch customAction.actionType {
            case .storePreviewNavigation:
                output.route.send(.presentNavigation(
                    latitude: config.latitude,
                    longitude: config.longitude,
                    storeName: state.storeName
                ))
            case .storePreviewShare:
                // STORE_TYPE 은 서버 extraParams 가 결정한다. (일반/사장님 가게 모두 가능, 누락 시 일반 가게)
                let storeType: StoreType
                if let rawValue = customAction.extraParams["STORE_TYPE"]?.anyValue as? String {
                    storeType = StoreType(value: rawValue)
                } else {
                    storeType = .userStore
                }
                output.route.send(.share(
                    storeId: config.storeId,
                    storeType: storeType,
                    storeName: state.storeName,
                    latitude: config.latitude,
                    longitude: config.longitude
                ))
            case .storePreviewReviewWrite:
                output.route.send(.presentReviewWrite(storeId: config.storeId))
            case .unknown:
                output.route.send(.pushStoreDetail(storeId: config.storeId))
            }
            return
        }

        if let link = bar.button.link {
            // 방문 인증은 customAction 이 아니라 APP_SCHEME 딥링크(/visit)로 내려온다.
            // 가게 상세의 방문 버튼과 동일하게 방문 인증 화면을 띄우고, 성공 시 미리보기를 갱신한다.
            if link.type == .appScheme, link.link.contains("/visit") {
                output.route.send(.presentVisit(storeId: config.storeId))
            } else {
                // 그 외 링크(가게/웹/기타 앱스킴)는 공용 딥링크 핸들러에 위임한다.
                output.route.send(.openLink(link))
            }
            return
        }

        output.route.send(.pushStoreDetail(storeId: config.storeId))
    }

    /// 우상단 찜 버튼 토글. 현재 찜 상태(state.isFavorited)를 기준으로 추가/삭제를 결정한다.
    private func toggleFavorite() async {
        let isDelete = state.isFavorited
        let result = await dependency.storeRepository.saveStore(
            storeId: String(config.storeId),
            isDelete: isDelete
        )
        switch result {
        case .success:
            state.isFavorited = isDelete.isNot
            output.isFavoriteOverride.send(state.isFavorited)
            // StoreDetail 즐겨찾기와 동일한 토스트 문구.
            let message = isDelete
                ? "즐겨찾기가 삭제되었습니다!"
                : "즐겨찾기가 추가되었습니다!"
            output.toast.send(message)
        case .failure:
            break
        }
    }
}
