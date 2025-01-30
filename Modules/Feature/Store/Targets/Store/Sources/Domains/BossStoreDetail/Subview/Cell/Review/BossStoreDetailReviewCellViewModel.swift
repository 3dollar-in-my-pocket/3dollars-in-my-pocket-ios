import Combine

import Common
import Networking
import Model
import DependencyInjection
import AppInterface
import Log

final class BossStoreDetailReviewCellViewModel: BaseViewModel {
    struct Input {
        let didTapRightButton = PassthroughSubject<Void, Never>()
        let didTapLikeButton = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        var review: StoreDetailReview
        let updateUI = PassthroughSubject<Void, Never>()
        let error = PassthroughSubject<Error, Never>()
        let onSuccessDelete = PassthroughSubject<Int, Never>()
        let presentReportBottomSheetReview = PassthroughSubject<(StoreDetailReview, [ReportReason]), Never>()
    }
    
    struct Config {
        let storeId: String
    }
    
    let input = Input()
    var output: Output
    
    private let config: Config
    private let reportRepository: ReportRepository
    private let reviewRepository: ReviewRepository
    private let logManager: LogManagerProtocol
    
    init(
        config: Config,
        data: StoreDetailReview,
        reportRepository: ReportRepository = ReportRepositoryImpl(),
        reviewRepository: ReviewRepository = ReviewRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
        self.output = Output(review: data)
        self.reportRepository = reportRepository
        self.reviewRepository = reviewRepository
        self.logManager = logManager
        
        super.init()
    }
    
    override func bind() {
        super.bind()
        
        input.didTapRightButton
            .withUnretained(self)
            .sink { (owner: BossStoreDetailReviewCellViewModel, _) in
                let review = owner.output.review
                if review.isOwner {
                    owner.deleteReview()
                } else {
                    owner.presentReportReviewBottomSheet(review: review)
                }
            }
            .store(in: &cancellables)
        
        input.didTapLikeButton
            .withUnretained(self)
            .sink { (owner: BossStoreDetailReviewCellViewModel, _) in
                owner.sendClickLike(isLiked: owner.output.review.reactedByMe)
                owner.toggleSticker()
            }
            .store(in: &cancellables)
    }
    
    private func presentReportReviewBottomSheet(review: StoreDetailReview) {
        Task {
            let reportReasonResult = await reportRepository.fetchReportReasons(group: .review)
                .map { response in
                    response.reasons.map { ReportReason(response: $0) }
                }
            
            switch reportReasonResult {
            case .success(let reasons):
                output.presentReportBottomSheetReview.send((output.review, reasons))
            case .failure(let error):
                output.error.send(error)
            }
        }
    }
    
    private func toggleSticker() {
        Task {
            var review = output.review
            let input = StoreReviewStickerListReplaceInput(stickers: review.reactedByMe ? [] : [.init(stickerId: review.stickerId)])
            let result = await reviewRepository.toggleReviewSticker(storeId: Int(config.storeId) ?? 0, reviewId: review.reviewId, input: input)
            
            switch result {
            case .success(_):
                if review.reactedByMe {
                    review.likeCount -= 1
                } else {
                    review.likeCount += 1
                }
                review.reactedByMe.toggle()
                output.review = review
                output.updateUI.send()
            case .failure(let error):
                output.error.send(error)
            }
        }
    }
    
    private func deleteReview() {
        Task {
            let result = await reviewRepository.deleteReview(reviewId: output.review.reviewId)
            switch result {
            case .success(_):
                output.onSuccessDelete.send(output.review.reviewId)
            case .failure(let error):
                output.error.send(error)
            }
        }
    }
    
    private func sendClickLike(isLiked: Bool) {
//        logManager.sendEvent(.init(
//            screen: output.screenName,
//            eventName: .clickLike,
//            extraParameters: [
//                .storeId: state.storeId,
//                .value: !isLiked
//            ]
//        ))
    }
}

extension BossStoreDetailReviewCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStoreDetailReviewCellViewModel: Hashable {
    static func == (lhs: BossStoreDetailReviewCellViewModel, rhs: BossStoreDetailReviewCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
