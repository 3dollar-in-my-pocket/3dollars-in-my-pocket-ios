import Combine
import UIKit

import AppInterface
import Common
import Log
import Model
import Networking
import WriteInterface

extension StoreSectionsViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let didSelectAction = PassthroughSubject<StoreSectionAction, Never>()
        let scrollToSectionFragment = PassthroughSubject<String, Never>()
    }

    struct Output {
        let sections = PassthroughSubject<[any StoreSectionComponent], Never>()
        let route = PassthroughSubject<Route, Never>()
        let error = PassthroughSubject<Error, Never>()
        let toast = PassthroughSubject<String, Never>()
    }

    enum Route {
        case presentWriteReview(ReviewBottomSheetViewModel)
        case presentMapDetail(MapDetailViewModel)
        case presentUploadPhoto(UploadPhotoViewModel)
        case presentPhotoDetail(PhotoDetailViewModel)
        case pushReviewList(ReviewListViewModel)
        case pushStoreDetail(Int)
        case presentCouponList
        case presentStoreReport(ReportBottomSheetViewModel)
        case presentReviewReport(ReportReviewBottomSheetViewModel)
        case pushEditStore(EditStoreViewModelInterface)
        case scrollToSection(StoreSectionType)
    }

    struct Config {
        let storeId: Int
        let latitude: Double
        let longitude: Double
    }

    struct Dependency {
        let storeRepository: StoreRepository
        let reportRepository: ReportRepository
        let reviewRepository: ReviewRepository
        let couponRepository: CouponRepository
        let logManager: LogManagerProtocol

        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            reportRepository: ReportRepository = ReportRepositoryImpl(),
            reviewRepository: ReviewRepository = ReviewRepositoryImpl(),
            couponRepository: CouponRepository = CouponRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.storeRepository = storeRepository
            self.reportRepository = reportRepository
            self.reviewRepository = reviewRepository
            self.couponRepository = couponRepository
            self.logManager = logManager
        }
    }

    struct State {
        var sections: [any StoreSectionComponent] = []
        var isLoading = false
        var pendingSectionFragment: String?
    }
}

final class StoreSectionsViewModel: BaseViewModel {
    let input = Input()
    let output = Output()

    private var state = State()
    private let config: Config
    private let dependency: Dependency

    var storeId: Int {
        config.storeId
    }

    init(config: Config, dependency: Dependency = Dependency()) {
        self.config = config
        self.dependency = dependency
        super.init()
    }

    override func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: StoreSectionsViewModel, _) in
                Task { [weak owner] in
                    await owner?.loadSections()
                }.store(in: owner.taskBag)
            }
            .store(in: &cancellables)

        input.didSelectAction
            .withUnretained(self)
            .sink { (owner: StoreSectionsViewModel, action) in
                owner.handle(action)
            }
            .store(in: &cancellables)

        input.scrollToSectionFragment
            .withUnretained(self)
            .sink { (owner: StoreSectionsViewModel, fragment: String) in
                owner.scrollToSectionIfPossible(fragment: fragment)
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func loadSections() async {
        guard !state.isLoading else { return }
        state.isLoading = true
        defer { state.isLoading = false }

        let result = await dependency.storeRepository.fetchStoreScreenV2(input: .init(
            storeId: String(config.storeId),
            latitude: config.latitude,
            longitude: config.longitude
        ))

        switch result {
        case .success(let response):
            state.sections = response.sections
            output.sections.send(response.sections)
            sendPageView(response.viewLog)

            if let fragment = state.pendingSectionFragment {
                state.pendingSectionFragment = nil
                scrollToSectionIfPossible(fragment: fragment)
            }
        case .failure(let error):
            output.error.send(error)
        }
    }

    private func handle(_ action: StoreSectionAction) {
        switch action {
        case let .custom(customAction, clickLog, cardId):
            sendClickLog(clickLog)
            handle(customAction, cardId: cardId)
        case let .link(link, clickLog):
            sendClickLog(clickLog)
            Environment.appModuleInterface.deepLinkHandler.handleLinkResponse(link)
        }
    }

    /// 탭 링크의 fragment(#info 등)를 화면에 존재하는 섹션 타입으로 해석해 스크롤한다.
    /// 아직 섹션 로드 전이면 보류해 두었다가 로드 완료 후 스크롤한다.
    private func scrollToSectionIfPossible(fragment: String) {
        guard state.sections.isEmpty.isNot else {
            state.pendingSectionFragment = fragment
            return
        }
        guard let sectionType = sectionType(fragment: fragment) else { return }

        output.route.send(.scrollToSection(sectionType))
    }

    private func sectionType(fragment: String) -> StoreSectionType? {
        let candidates: [StoreSectionType]
        switch fragment.lowercased() {
        case "home":
            candidates = [.preview]
        case "info":
            candidates = [.infoV1, .infoV2]
        case "images":
            candidates = [.image]
        case "reviews":
            candidates = [.review]
        default:
            candidates = []
        }

        let loadedTypes = Set(state.sections.map(\.type))
        return candidates.first { loadedTypes.contains($0) }
    }

    private func handle(_ action: SDCustomAction, cardId: String?) {
        switch action.actionType {
        case .storeEditCopyAddress:
            guard let address = action.extraParams["ADDRESS"]?.stringValue else { return }
            UIPasteboard.general.string = address
            output.toast.send(Strings.StoreDetail.Toast.copyToAddress)
        case .storeEditMapEnlarge:
            output.route.send(.presentMapDetail(makeMapDetailViewModel()))
        case .storeReviewWrite, .storePreviewReviewWrite:
            output.route.send(.presentWriteReview(makeReviewBottomSheetViewModel()))
        case .storeImageAddImage:
            output.route.send(.presentUploadPhoto(makeUploadPhotoViewModel()))
        case .storeImageEnlarge:
            guard let imageId = action.intParam("IMAGE_ID"), let imageURL = action.stringParam("IMAGE_URL") else { return }
            presentPhotoDetail(imageId: imageId, imageURL: imageURL)
        case .storeEditUpdate:
            guard let storeId = action.stringParam("STORE_ID") else { return }
            presentEditStore(storeId: storeId)
        case .storeEditReport:
            guard let storeId = action.intParam("STORE_ID") else { return }
            presentStoreReport(storeId: storeId)
        case .storeReviewReport:
            let storeId = action.intParam("STORE_ID") ?? config.storeId
            guard let reviewId = action.intParam("REVIEW_ID") ?? reviewId(from: cardId) else { return }
            presentReviewReport(storeId: storeId, reviewId: reviewId)
        case .storeReviewDelete:
            guard let reviewId = action.intParam("REVIEW_ID") ?? reviewId(from: cardId) else { return }
            deleteReview(reviewId: reviewId)
        case .storeReviewAddLike, .storeReviewCancelLike:
            let storeId = action.intParam("STORE_ID") ?? config.storeId
            guard
                  let reviewId = action.intParam("REVIEW_ID") ?? reviewId(from: cardId),
                  let stickerId = action.stringParam("STICKER_ID") else { return }
            toggleReviewSticker(storeId: storeId, reviewId: reviewId, stickerId: stickerId, isLiked: action.actionType == .storeReviewCancelLike)
        case .storePostAddLike, .storePostCancelLike:
            togglePostSticker(action, isLiked: action.actionType == .storePostCancelLike)
        case .storeCouponIssue:
            guard let storeId = action.stringParam("STORE_ID"), let couponId = action.stringParam("COUPON_ID") else { return }
            issueCoupon(storeId: storeId, couponId: couponId)
        case .storeCouponUse:
            guard let issuedKey = action.stringParam("COUPON_ISSUED_KEY") else { return }
            useCoupon(issuedKey: issuedKey)
        case .unknown where action.stringParam("POST_ID") != nil:
            // The server currently sends STORE_POST_SECTION_LIKE, which decodes as unknown.
            togglePostSticker(action, isLiked: false)
        case .storePreviewShare, .storePreviewNavigation, .unknown:
            break
        }
    }

    private func makeReviewBottomSheetViewModel() -> ReviewBottomSheetViewModel {
        let viewModel = ReviewBottomSheetViewModel(config: .init(storeId: config.storeId, review: nil))
        // 리뷰 작성 성공 시 섹션을 다시 조회해 리뷰 목록·평균 별점을 갱신한다.
        viewModel.output.onSuccessWriteReview
            .withUnretained(self)
            .sink { (owner: StoreSectionsViewModel, _) in
                owner.input.load.send(())
            }
            .store(in: &viewModel.cancellables)
        return viewModel
    }

    private func makeMapDetailViewModel() -> MapDetailViewModel {
        MapDetailViewModel(config: .init(
            location: .init(latitude: config.latitude, longitude: config.longitude),
            storeName: ""
        ))
    }

    private func makeUploadPhotoViewModel() -> UploadPhotoViewModel {
        UploadPhotoViewModel(config: .init(uploadType: .storeImage(storeId: config.storeId)))
    }

    private func presentPhotoDetail(imageId: Int, imageURL: String) {
        Task { [weak self] in
            guard let self else { return }
            let result = await dependency.storeRepository.fetchStorePhotos(storeId: config.storeId, cursor: nil)
            switch result {
            case .success(let response):
                let photos = response.contents.map { StoreDetailPhoto(response: $0.image) }
                let currentIndex = photos.firstIndex { $0.imageId == imageId || $0.url == imageURL } ?? 0
                let viewModel = PhotoDetailViewModel(config: .init(
                    storeId: config.storeId,
                    photos: photos,
                    nextCursor: response.cursor.nextCursor,
                    hasMore: response.cursor.hasMore,
                    currentIndex: currentIndex
                ))
                output.route.send(.presentPhotoDetail(viewModel))
            case .failure(let error):
                output.error.send(error)
            }
        }
    }

    private func makeReviewListViewModel() -> ReviewListViewModel {
        ReviewListViewModel(config: .init(storeId: config.storeId, isBossStore: false))
    }

    private func presentEditStore(storeId: String) {
        Task { [weak self] in
            guard let self, let storeId = Int(storeId) else { return }
            let result = await dependency.storeRepository.fetchStoreDetail(input: .init(storeId: storeId, reviewsCount: 0))
            switch result {
            case .success(let response):
                let viewModel = Environment.writeInterface.createEditStoreViewModel(config: .init(
                    store: response.store,
                    fromScreen: .storeDetail,
                    imageCount: nil
                ))
                output.route.send(.pushEditStore(viewModel))
            case .failure(let error):
                output.error.send(error)
            }
        }
    }

    private func presentStoreReport(storeId: Int) {
        Task { [weak self] in
            guard let self else { return }
            let result = await dependency.reportRepository.fetchReportReasons(group: .store)
            switch result {
            case .success(let response):
                output.route.send(.presentStoreReport(.init(config: .init(
                    storeId: storeId,
                    reportReasons: response.reasons.map(ReportReason.init)
                ))))
            case .failure(let error):
                output.error.send(error)
            }
        }
    }

    private func presentReviewReport(storeId: Int, reviewId: Int) {
        Task { [weak self] in
            guard let self else { return }
            let result = await dependency.reportRepository.fetchReportReasons(group: .review)
            switch result {
            case .success(let response):
                output.route.send(.presentReviewReport(.init(config: .init(
                    storeId: storeId,
                    reviewId: reviewId,
                    reportReasons: response.reasons.map(ReportReason.init)
                ))))
            case .failure(let error):
                output.error.send(error)
            }
        }
    }

    private func deleteReview(reviewId: Int) {
        Task { [weak self] in
            guard let self else { return }
            let result = await dependency.reviewRepository.deleteReview(reviewId: reviewId)
            switch result {
            case .success:
                input.load.send(())
            case .failure(let error):
                output.error.send(error)
            }
        }
    }

    private func toggleReviewSticker(storeId: Int, reviewId: Int, stickerId: String, isLiked: Bool) {
        Task { [weak self] in
            guard let self else { return }
            let input = StoreReviewStickerListReplaceInput(stickers: isLiked ? [] : [.init(stickerId: stickerId)])
            let result = await dependency.reviewRepository.toggleReviewSticker(storeId: storeId, reviewId: reviewId, input: input)
            switch result {
            case .success:
                self.input.load.send(())
            case .failure(let error):
                output.error.send(error)
            }
        }
    }

    private func togglePostSticker(_ action: SDCustomAction, isLiked: Bool) {
        guard let storeId = action.stringParam("STORE_ID"),
              let postId = action.stringParam("POST_ID"),
              let stickerId = action.stringParam("STICKER_ID") else { return }
        Task { [weak self] in
            guard let self else { return }
            let input = StoreNewsPostStickersReplaceRequest(stickers: isLiked ? [] : [.init(stickerId: stickerId)])
            let result = await dependency.storeRepository.togglePostSticker(storeId: storeId, postId: postId, input: input)
            switch result {
            case .success:
                self.input.load.send(())
            case .failure(let error):
                output.error.send(error)
            }
        }
    }

    private func issueCoupon(storeId: String, couponId: String) {
        Task { [weak self] in
            guard let self else { return }
            let result = await dependency.couponRepository.issueStoreCoupon(storeId: storeId, couponId: couponId)
            switch result {
            case .success:
                output.toast.send("쿠폰을 발급받았어요!")
                input.load.send(())
            case .failure(let error):
                output.error.send(error)
            }
        }
    }

    private func useCoupon(issuedKey: String) {
        Task { [weak self] in
            guard let self else { return }
            let result = await dependency.couponRepository.useIssuedCoupon(issuedKey: issuedKey)
            switch result {
            case .success:
                output.toast.send("쿠폰을 사용했어요!")
                input.load.send(())
            case .failure(let error):
                output.error.send(error)
            }
        }
    }

    private func reviewId(from cardId: String?) -> Int? {
        guard let cardId, cardId.hasPrefix("R:") else { return nil }
        return Int(cardId.dropFirst(2))
    }

    private func sendPageView(_ log: SDPageViewLog) {
        let parameters = log.extraParameters.reduce(into: [ParameterName: Any]()) { result, item in
            result[ParameterName(rawValue: item.key)] = item.value
        }
        dependency.logManager.sendPageView(
            screen: ScreenName(rawValue: log.screenName),
            type: StoreSectionsViewController.self,
            extraParameters: parameters
        )
    }

    private func sendClickLog(_ clickLog: SDClickLog?) {
        guard let clickLog else { return }
        dependency.logManager.sendEvent(event: ClickEvent(clickLog: clickLog))
    }

    func sendImpressionLog(_ impressionLog: SDImpressionLog?) {
        guard let impressionLog else { return }
        dependency.logManager.sendEvent(event: ImpressionEvent(impressionLog: impressionLog))
    }
}

private extension SDCustomAction {
    func stringParam(_ key: String) -> String? {
        guard let value = extraParams[key] else { return nil }
        if let value = value.stringValue { return value }
        if let value = value.doubleValue {
            return value.rounded() == value ? String(Int(value)) : String(value)
        }
        return nil
    }

    func intParam(_ key: String) -> Int? {
        stringParam(key).flatMap(Int.init)
    }
}
