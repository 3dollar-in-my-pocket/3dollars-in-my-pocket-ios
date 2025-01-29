import UIKit
import Combine

import Common
import DesignSystem
import Model
import Networking
import Log

final class ReviewWriteViewModel: BaseViewModel {
    struct Input {
        let didTapCompleteButton = PassthroughSubject<Void, Never>()
        let load = PassthroughSubject<Void, Never>()
        let didTapRating = PassthroughSubject<Int, Never>()
        let inputReview = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        let feedbackSelectionViewModel: ReviewFeedbackSelectionViewModel
        let errorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
        let isEnableWriteButton = CurrentValueSubject<Bool, Never>(false)
        let onSuccessWriteReview = PassthroughSubject<StoreDetailReview, Never>()
    }
    
    enum Route {
        case dismiss
    }
    
    struct Config {
        let storeId: String
        let feedbackTypes: [FeedbackType]
    }
    
    struct State {
        var rating: Int?
        var contents: String?
        var nonceToken: String?
    }
    
    let input = Input()
    let output: Output
    
    private let config: Config
    private let storeService: StoreRepository
    private let commonRepository: CommonRepository
    private let logManager: LogManagerProtocol
    private var state: State
    
    init(
        config: Config,
        storeService: StoreRepository = StoreRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared,
        commonRepository: CommonRepository = CommonRepositoryImpl()
    ) {
        self.config = config
        self.storeService = storeService
        self.logManager = logManager
        self.commonRepository = commonRepository
        self.output = Output(feedbackSelectionViewModel: .init(storeId: config.storeId, feedbackTypes: config.feedbackTypes))
        self.state = State(rating: nil, contents: nil)
    }
    
    override func bind() {
        input.didTapCompleteButton
            .withUnretained(self)
            .sink { (owner: ReviewWriteViewModel, _) in
                owner.writeReview()
            }
            .store(in: &cancellables)
        
        input.load
            .withUnretained(self)
            .sink { (owner: ReviewWriteViewModel, _) in
                owner.createNonceToken()
            }
            .store(in: &cancellables)
        
        input.didTapRating
            .withUnretained(self)
            .sink { (owner: ReviewWriteViewModel, rating: Int) in
                owner.state.rating = rating
                owner.output.isEnableWriteButton.send(owner.isEnableWriteButton())
            }
            .store(in: &cancellables)
        
        input.inputReview
            .withUnretained(self)
            .sink { (owner: ReviewWriteViewModel, contents: String) in
                owner.state.contents = contents
                owner.output.isEnableWriteButton.send(owner.isEnableWriteButton())
            }
            .store(in: &cancellables)
    }
    
    private func writeReview() {
        guard let rating = state.rating,
              let contents = state.contents,
              let nonceToken = state.nonceToken else { return }
        
        
        let feedbacks: [WriteReviewRequestInput.Feedback] = output.feedbackSelectionViewModel.output.selectedFeedbacks.map { WriteReviewRequestInput.Feedback(emojiType: $0.rawValue) }
        
        Task {
            let input = WriteReviewRequestInput(
                storeId: Int(config.storeId) ?? 0,
                contents: contents,
                rating: rating,
                nonceToken: nonceToken,
                feedbacks: feedbacks
            )
            
            let result = await storeService.writeReview(input: input)
            
            switch result {
            case .success(let response):
                let storeDetailReview = StoreDetailReview(response: response)
                output.onSuccessWriteReview.send(storeDetailReview)
                output.route.send(.dismiss)
                
            case .failure(let error):
                output.errorAlert.send(error)
            }
        }
    }
    
    private func createNonceToken() {
        Task {
            let result = await commonRepository.createNonceToken()
            
            switch result {
            case .success(let response):
                state.nonceToken = response.nonce
            case .failure(let error):
                output.errorAlert.send(error)
            }
        }
    }
    
    private func isEnableWriteButton() -> Bool {
        guard let _ = state.rating,
              let contents = state.contents,
                output.feedbackSelectionViewModel.output.isEnabledButton.value else { return false }
        
        return contents.isNotEmpty
    }
}
