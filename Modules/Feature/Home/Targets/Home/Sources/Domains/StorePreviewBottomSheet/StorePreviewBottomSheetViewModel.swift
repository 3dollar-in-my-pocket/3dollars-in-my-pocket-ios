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
        let didTapDetailShare = PassthroughSubject<Void, Never>()
        let didTapActionBar = PassthroughSubject<Int, Never>()
        let didTapAddPhoto = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let section = PassthroughSubject<StorePreviewSection, Never>()
        let detailTitle = PassthroughSubject<String, Never>()
        let pageViewLog = PassthroughSubject<SDPageViewLog, Never>()
        let toast = PassthroughSubject<String, Never>()
        let isFavoriteOverride = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    enum Route {
        case expandPanel
        case presentVisit(storeId: Int)
        case presentReviewWrite(storeId: Int)
        case share(storeId: Int, storeName: String, latitude: Double, longitude: Double)
        case presentNavigation(latitude: Double, longitude: Double, storeName: String)
        case openLink(SDLink)
        case presentUploadPhoto(storeId: Int)
        case presentDisplayItemModal(StoreDisplayItemType, StoreDisplayTrigger?)
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
        let preference: Preference

        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared,
            preference: Preference = .shared
        ) {
            self.storeRepository = storeRepository
            self.logManager = logManager
            self.preference = preference
        }
    }

    struct State {
        var section: StorePreviewSection?
        var storeName: String = ""
        var isFavorited: Bool = false
        var isLoadingPreview: Bool = false
        var isLoadingDisplayItems: Bool = false
        var emittedDisplayItemTypes: Set<StoreDisplayItemType> = []
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
    var latitude: Double { config.latitude }
    var longitude: Double { config.longitude }

    override func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: StorePreviewBottomSheetViewModel, _) in
                Task { [weak owner] in
                    await owner?.fetchPreview()
                }
                Task { [weak owner] in
                    await owner?.fetchDisplayItems()
                }
            }
            .store(in: &cancellables)

        input.didTapBody
            .withUnretained(self)
            .sink { (owner: StorePreviewBottomSheetViewModel, _) in
                owner.output.route.send(.expandPanel)
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

        input.didTapDetailShare
            .withUnretained(self)
            .sink { (owner: StorePreviewBottomSheetViewModel, _) in
                owner.output.route.send(.share(
                    storeId: owner.config.storeId,
                    storeName: owner.state.storeName,
                    latitude: owner.config.latitude,
                    longitude: owner.config.longitude
                ))
            }
            .store(in: &cancellables)

        input.didTapActionBar
            .withUnretained(self)
            .sink { (owner: StorePreviewBottomSheetViewModel, index: Int) in
                guard let bar = owner.state.section?.actionBars[safe: index] else { return }
                owner.handleActionBar(bar)
            }
            .store(in: &cancellables)

        input.didTapAddPhoto
            .withUnretained(self)
            .sink { (owner: StorePreviewBottomSheetViewModel, _) in
                owner.output.route.send(.presentUploadPhoto(storeId: owner.config.storeId))
            }
            .store(in: &cancellables)
    }

    private func fetchPreview() async {
        guard !state.isLoadingPreview else { return }
        state.isLoadingPreview = true
        defer { state.isLoadingPreview = false }

        let deviceLocation = dependency.preference.userCurrentLocation
        let input = FetchStoreScreenInput(
            storeId: String(config.storeId),
            latitude: deviceLocation.coordinate.latitude,
            longitude: deviceLocation.coordinate.longitude
        )
        let result = await dependency.storeRepository.fetchStorePreview(input: input)

        switch result {
        case .success(let response):
            guard let preview = response.sections.compactMap({ $0 as? StorePreviewSection }).first else { return }
            state.section = preview
            // header.title 은 스타일이 담긴 HTML 이라 그대로 쓰면 네비 타이틀·공유 문구에 태그가 노출된다.
            state.storeName = preview.header.title.map { $0.isHtml ? $0.text.htmlStripped : $0.text } ?? ""
            // 서버의 isSubscriber 값으로 저장 버튼 초기 선택 상태를 동기화한다.
            state.isFavorited = preview.additionalInfos?.isSubscriber ?? false
            output.section.send(preview)
            output.detailTitle.send(state.storeName)
            output.isFavoriteOverride.send(state.isFavorited)
            output.pageViewLog.send(response.viewLog)
        case .failure:
            break
        }
    }

    /// 바텀시트 랜딩 시 활동 유도 항목을 조회한다. 레거시 가게 상세와 동일하게
    /// 세션 내 같은 가게 조회 횟수 조건을 만족하는 visible 항목만 처리한다.
    private func fetchDisplayItems() async {
        guard !state.isLoadingDisplayItems else { return }
        state.isLoadingDisplayItems = true
        defer { state.isLoadingDisplayItems = false }

        let viewCount = StoreViewSessionCounter.shared.increment(storeId: config.storeId)
        let itemTypes: [StoreDisplayItemType] = [
            .disappearanceInquiryModal,
            .visitCertificationInducementModal
        ]
        let result = await dependency.storeRepository.fetchDisplayItems(
            storeId: config.storeId,
            itemTypes: itemTypes
        )

        guard case let .success(response) = result else { return }

        for item in response.contents where item.isVisible {
            guard meetsSessionViewCountCondition(trigger: item.trigger, viewCount: viewCount),
                  state.emittedDisplayItemTypes.insert(item.itemType).inserted else {
                continue
            }

            output.route.send(.presentDisplayItemModal(item.itemType, item.trigger))
        }
    }

    private func meetsSessionViewCountCondition(trigger: StoreDisplayTrigger?, viewCount: Int) -> Bool {
        guard let range = trigger?.conditions?.sessionViewCountRange else { return true }
        return range.contains(viewCount)
    }

    /// 레거시 상세처럼 모달 슬라이드인 애니메이션이 완료된 뒤에만 impression 을 기록한다.
    func recordDisplayItemImpression(itemType: StoreDisplayItemType) {
        Task { [weak self] in
            guard let self else { return }
            _ = await dependency.storeRepository.recordDisplayItemImpression(
                storeId: config.storeId,
                itemTypes: [itemType]
            )
        }
    }

    private func handleActionBar(_ bar: StorePreviewActionBar) {
        dependency.logManager.sendEvent(event: ClickEvent(clickLog: bar.clickLog))

        if let customAction = bar.button.customAction {
            switch customAction.actionType {
            case .storePreviewNavigation:
                let extraParams = customAction.extraParams
                output.route.send(.presentNavigation(
                    latitude: extraParams["LATITUDE"]?.doubleValue ?? config.latitude,
                    longitude: extraParams["LONGITUDE"]?.doubleValue ?? config.longitude,
                    storeName: extraParams["STORE_NAME"]?.stringValue ?? state.storeName
                ))
            case .storePreviewShare:
                output.route.send(.share(
                    storeId: config.storeId,
                    storeName: state.storeName,
                    latitude: config.latitude,
                    longitude: config.longitude
                ))
            case .storePreviewReviewWrite:
                output.route.send(.presentReviewWrite(storeId: config.storeId))
            default:
                // 미리보기 섹션과 무관한 액션(상세 전용 섹션의 커스텀 액션 등)은 상세 확장으로 처리한다.
                output.route.send(.expandPanel)
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

        output.route.send(.expandPanel)
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
