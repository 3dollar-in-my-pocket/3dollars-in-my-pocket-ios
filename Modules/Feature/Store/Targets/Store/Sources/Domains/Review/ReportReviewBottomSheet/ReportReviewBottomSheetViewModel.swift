import Foundation
import Combine

import Common
import Networking
import Model

final class ReportReviewBottomSheetViewModel: BaseViewModel {
    
    struct Input {
        let didTapReason = PassthroughSubject<Int, Never>()
        let didTapReport = PassthroughSubject<Void, Never>()
        let inputReasonDetail = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        let sectionItems: CurrentValueSubject<[ReportReviewSectionItem], Never>
        let isEnableReport = CurrentValueSubject<Bool, Never>(false)
        let onSuccessReport = PassthroughSubject<Int, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }
    
    struct State {
        var reportReasons: [ReportReason]
        var selectedReasone: ReportReason?
        var hasReasonDetail: Bool = false
        var reasonDetail: String?
    }
    
    struct Config {
        let storeId: Int
        let reviewId: Int
        let reportReasons: [ReportReason]
    }
    
    enum Route {
        case dismiss
    }
    
    let input = Input()
    let output: Output
    var state: State
    private let config: Config
    private let reviewRepository: ReviewRepository
    
    init(config: Config, reviewRepository: ReviewRepository = ReviewRepositoryImpl()) {
        self.output = Output(sectionItems: .init(config.reportReasons.map { .reason(item: $0) }))
        self.config = config
        self.state = State(reportReasons: config.reportReasons)
        self.reviewRepository = reviewRepository
        
        super.init()
    }
    
    override func bind() {
        input.didTapReason
            .withUnretained(self)
            .sink { (owner: ReportReviewBottomSheetViewModel, index: Int) in
                guard let reason = owner.state.reportReasons[safe: index] else { return }
                
                owner.state.selectedReasone = reason
                owner.output.isEnableReport.send(true)
                
                let sectionItems: [ReportReviewSectionItem] = owner.state.reportReasons.map { .reason(item: $0) }
                if reason.hasReasonDetail {
                    owner.state.hasReasonDetail = true
                    owner.output.sectionItems.send(sectionItems + [.reasonDetail])
                } else {
                    owner.state.hasReasonDetail = false
                    owner.output.sectionItems.send(sectionItems)
                }
            }
            .store(in: &cancellables)
        
        input.didTapReport
            .withUnretained(self)
            .sink { (owner: ReportReviewBottomSheetViewModel, _) in
                guard let reason = owner.state.selectedReasone else { return }
                let reasonDetail = reason.hasReasonDetail ? owner.state.reasonDetail : nil
                owner.reportReview(reason: reason, reasonDetail: reasonDetail)
            }
            .store(in: &cancellables)
        
        input.inputReasonDetail
            .withUnretained(self)
            .sink { (owner: ReportReviewBottomSheetViewModel, text: String) in
                owner.state.reasonDetail = text
            }
            .store(in: &cancellables)
    }
    
    private func reportReview(reason: ReportReason, reasonDetail: String?) {
        Task {
            let input = ReportReviewRequestInput(reason: reason.type, reasonDetail: reasonDetail)
            let reportResult = await reviewRepository.reportReview(
                storeId: config.storeId,
                reviewId: config.reviewId,
                input: input
            )
            
            switch reportResult {
            case .success(_):
                output.onSuccessReport.send(config.reviewId)
                output.route.send(.dismiss)
                
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
}
