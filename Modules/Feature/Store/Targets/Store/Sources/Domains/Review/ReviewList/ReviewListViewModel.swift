import Foundation
import Combine

import Common
import Model
import Networking
import Log

final class ReviewListViewModel: BaseViewModel {
    enum Constant {
        static let pageSize = 20
    }
    
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
        let didTapSortType = PassthroughSubject<SubtabStackView.SortType, Never>()
        let didTapRightButton = PassthroughSubject<Int, Never>()
        let didTapReviewLikeButton = PassthroughSubject<Int, Never>()
        let didTapWrite = PassthroughSubject<Void, Never>()
        let onSuccessWriteReview = PassthroughSubject<StoreDetailReview, Never>()
        let onSuccessEditReview = PassthroughSubject<StoreReviewResponse, Never>()
        let onSuccessReportReview = PassthroughSubject<Int, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .reviewList
        let sortType = CurrentValueSubject<SubtabStackView.SortType, Never>(.latest)
        let sections = PassthroughSubject<[ReviewListSection], Never>()
        let scrollToTop = PassthroughSubject<Void, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
        
        // StoreDetailViewModel 전달용 이벤트
        let onSuccessWriteReview = PassthroughSubject<StoreDetailReview, Never>()
        let onSuccessEditReview = PassthroughSubject<StoreReviewResponse, Never>()
        let onSuccessReportReview = PassthroughSubject<Int, Never>()
        let onSuccessToggleReviewSticker = PassthroughSubject<StoreDetailReview, Never>()
        let onSuccessDeleteReview = PassthroughSubject<Int, Never>()
    }
    
    struct State {
        var reviews: [StoreDetailReview] = []
        var cursor: String?
        var sortType: SubtabStackView.SortType = .latest
        var hasMore: Bool = true
    }
    
    enum Route {
        case presentWriteReview(ReviewBottomSheetViewModel)
        case presentReportBottomSheetReview(ReportReviewBottomSheetViewModel)
    }
    
    public struct Config {
        public let storeId: Int
        public let isBossStore: Bool
        
        public init(storeId: Int, isBossStore: Bool) {
            self.storeId = storeId
            self.isBossStore = isBossStore
        }
    }
    
    let input = Input()
    let output = Output()
    private let config: Config
    private var state = State()
    private let reviewRepository: ReviewRepository
    private let reportRepository: ReportRepository
    private let logManager: LogManagerProtocol
    private let preference = Preference.shared
    
    init(
        config: Config,
        reviewRepository: ReviewRepository = ReviewRepositoryImpl(),
        reportRepository: ReportRepository = ReportRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
        self.reviewRepository = reviewRepository
        self.reportRepository = reportRepository
        self.logManager = logManager
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, _) in
                owner.fetchReviewList()
            }
            .store(in: &cancellables)
        
        input.willDisplayCell
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, index: Int) in
                guard owner.canLoadMore(index: index) else { return }
                owner.fetchReviewList()
            }
            .store(in: &cancellables)
        
        input.didTapSortType
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, sortType: SubtabStackView.SortType) in
                guard owner.state.sortType != sortType else { return }
                owner.state.sortType = sortType
                owner.state.cursor = nil
                owner.state.reviews.removeAll()
                owner.fetchReviewList()
                owner.output.scrollToTop.send(())
                owner.sendClickSortLog(sortType: sortType)
            }
            .store(in: &cancellables)
        
        input.didTapRightButton
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, index: Int) in
                guard let review = owner.state.reviews[safe: index] else { return }
                
                if review.user.userId == owner.preference.userId {
                    owner.sendClickDeleteReviewLog(reviewId: review.reviewId)
                    owner.deleteReview(index: index)
                } else {
                    owner.sendClickReportReviewLog(reviewId: review.reviewId)
                    owner.presentReportReviewBottomSheet(review: review)
                }
            }
            .store(in: &cancellables)
        
        input.didTapWrite
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, _) in
                if owner.config.isBossStore.isNot {
                    owner.presentWriteReviewBottomSheet(review: nil)
                }
                owner.sendClickWriteReviewLog()
            }
            .store(in: &cancellables)
        
        input.onSuccessWriteReview
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, _) in
                owner.state.sortType = .latest
                owner.output.sortType.send(owner.state.sortType)
                owner.state.cursor = nil
                owner.state.reviews.removeAll()
                owner.fetchReviewList()
            }
            .store(in: &cancellables)
        
        input.onSuccessWriteReview
            .subscribe(output.onSuccessWriteReview)
            .store(in: &cancellables)
        
        input.onSuccessEditReview
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, response: StoreReviewResponse) in
                owner.updateReview(response)
            }
            .store(in: &cancellables)
        
        input.onSuccessEditReview
            .subscribe(output.onSuccessEditReview)
            .store(in: &cancellables)
        
        input.onSuccessReportReview
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, reviewId: Int) in
                guard let targetIndex = owner.state.reviews.firstIndex(where: { $0.reviewId == reviewId }) else { return }
                
                owner.state.reviews[targetIndex].isFiltered = true
                owner.output.sections.send(owner.getReviewListSection())
            }
            .store(in: &cancellables)
        
        input.onSuccessReportReview
            .subscribe(output.onSuccessReportReview)
            .store(in: &cancellables)
        
        input.didTapReviewLikeButton
            .withUnretained(self)
            .sink { (owner: ReviewListViewModel, index: Int) in
                owner.sendClickLike(index: index)
                owner.toggleSticker(index: index)
            }
            .store(in: &cancellables)
    }
    
    private func fetchReviewList() {
        Task {
            let input = FetchStoreReviewRequestInput(
                size: Constant.pageSize,
                cursor: state.cursor,
                sort: state.sortType.rawValue
            )
            let result = await reviewRepository.fetchStoreReview(storeId: config.storeId, input: input)
            
            switch result {
            case .success(let response):
                state.hasMore = response.cursor.hasMore
                state.cursor = response.cursor.nextCursor
                state.reviews.append(contentsOf: response.contents.map {
                    StoreDetailReview(response: $0)
                })
                output.sections.send(getReviewListSection())
                
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func canLoadMore(index: Int) -> Bool {
        return state.hasMore && state.cursor != nil && (index == state.reviews.count - 1)
    }
    
    private func presentWriteReviewBottomSheet(review: StoreDetailReview?) {
        let config = ReviewBottomSheetViewModel.Config(storeId: config.storeId, review: review)
        let viewModel = ReviewBottomSheetViewModel(config: config)
        
        viewModel.output.onSuccessWriteReview
            .subscribe(input.onSuccessWriteReview)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.onSuccessEditReview
            .subscribe(input.onSuccessEditReview)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentWriteReview(viewModel))
    }
    
    private func updateReview(_ review: StoreReviewResponse) {
        guard let targetIndex = state.reviews.firstIndex(where: {
            $0.reviewId == review.reviewId
        }) else { return }
        
        state.reviews[targetIndex].rating = review.rating
        state.reviews[targetIndex].contents = review.contents
        output.sections.send(getReviewListSection())
    }
    
    private func getReviewListSection() -> [ReviewListSection] {
        var sectionItems: [ReviewListSectionItem] = []
        
        for review in state.reviews {
            if review.isFiltered {
                sectionItems.append(.filtered(review))
            } else {
                sectionItems.append(.review(review))
            }
        }
        
        return [.init(type: .list, items: sectionItems)]
    }
    
    private func presentReportReviewBottomSheet(review: StoreDetailReview) {
        Task {
            let reportReasonResult = await reportRepository.fetchReportReasons(group: .review)
                .map { response in
                    response.reasons.map { ReportReason(response: $0) }
                }
            
            switch reportReasonResult {
            case .success(let reasons):
                let viewModel = createReportReviewBottomSheetViewModel(review: review, reasons: reasons)
                
                output.route.send(.presentReportBottomSheetReview(viewModel))
                
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func createReportReviewBottomSheetViewModel(
        review: StoreDetailReview,
        reasons: [ReportReason]
    ) -> ReportReviewBottomSheetViewModel {
        let config = ReportReviewBottomSheetViewModel.Config(
            storeId: config.storeId,
            reviewId: review.reviewId,
            reportReasons: reasons
        )
        let viewModel = ReportReviewBottomSheetViewModel(config: config)
        
        viewModel.output
            .onSuccessReport
            .subscribe(input.onSuccessReportReview)
            .store(in: &viewModel.cancellables)
        
        return viewModel
    }
    
    private func toggleSticker(index: Int) {
        guard let review = state.reviews[safe: index] else { return }
        
        Task {
            let input = StoreReviewStickerListReplaceInput(stickers: review.reactedByMe ? [] : [.init(stickerId: review.stickerId)])
            let result = await reviewRepository.toggleReviewSticker(storeId: config.storeId, reviewId: review.reviewId, input: input)
            
            switch result {
            case .success(_):
                if review.reactedByMe {
                    state.reviews[index].likeCount -= 1
                } else {
                    state.reviews[index].likeCount += 1
                }
                state.reviews[index].reactedByMe.toggle()
                output.sections.send(getReviewListSection())
                output.onSuccessToggleReviewSticker.send(state.reviews[index])
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func deleteReview(index: Int) {
        guard let review = state.reviews[safe: index] else { return }
        
        Task {
            let result = await reviewRepository.deleteReview(reviewId: review.reviewId)
            switch result {
            case .success(_):
                state.reviews.remove(at: index)
                output.sections.send(getReviewListSection())
                output.onSuccessDeleteReview.send(review.reviewId)
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
}

// MARK: Log
extension ReviewListViewModel {
    private func sendClickSortLog(sortType: SubtabStackView.SortType) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickSort,
            extraParameters: [
                .type: sortType.rawValue
            ]
        ))
    }
    
    private func sendClickDeleteReviewLog(reviewId: Int) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickDeleteReview,
            extraParameters: [
                .reviewId: reviewId
            ]
        ))
    }
    
    private func sendClickReportReviewLog(reviewId: Int) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickReport,
            extraParameters: [
                .reviewId: reviewId
            ]
        ))
    }
    
    private func sendClickWriteReviewLog() {
        logManager.sendEvent(.init(screen: output.screenName, eventName: .clickWriteReview))
    }
    
    private func sendClickLike(index: Int) {
        guard let review = state.reviews[safe: index] else { return }
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickLike,
            extraParameters: [
                .reviewId: review.reviewId,
                .value: !review.reactedByMe
            ]
        ))
    }
}
