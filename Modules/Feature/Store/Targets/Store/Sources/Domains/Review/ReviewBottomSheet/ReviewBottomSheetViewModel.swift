import UIKit
import Combine

import Common
import DesignSystem
import Model
import Networking
import Log

final class ReviewBottomSheetViewModel: BaseViewModel {
    struct Input {
        let didTapRating = PassthroughSubject<Int, Never>()
        let inputReview = PassthroughSubject<String, Never>()
        let didTapWrite = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .reviewBottomSheet
        let rating: CurrentValueSubject<Int?, Never>
        let contents: CurrentValueSubject<String?, Never>
        let isEnableWriteButton: CurrentValueSubject<Bool, Never>
        let onSuccessWriteReview = PassthroughSubject<StoreDetailReview, Never>()
        let onSuccessEditReview = PassthroughSubject<StoreReviewResponse, Never>()
        let errorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var rating: Int?
        var contents: String?
    }
    
    enum Route {
        case dismiss
    }
    
    struct Config {
        let storeId: Int
        let review: StoreDetailReview?
    }
    
    let input = Input()
    let output: Output
    private let storeService: StoreRepository
    private let logManager: LogManagerProtocol
    private let config: Config
    private var state: State
    
    init(
        config: Config,
        storeService: StoreRepository = StoreRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
        self.storeService = storeService
        self.logManager = logManager
        
        let isEnableWriteButton = (config.review?.contents != nil) && (config.review?.rating != nil)
        self.output = Output(
            rating: .init(config.review?.rating),
            contents: .init(config.review?.contents),
            isEnableWriteButton: .init(isEnableWriteButton)
        )
        self.state = State(rating: config.review?.rating, contents: config.review?.contents)
    }
    
    override func bind() {
        input.didTapRating
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewModel, rating: Int) in
                owner.state.rating = rating
                owner.output.isEnableWriteButton.send(owner.isEnableWriteButton())
            }
            .store(in: &cancellables)
        
        input.inputReview
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewModel, contents: String) in
                owner.state.contents = contents
                owner.output.isEnableWriteButton.send(owner.isEnableWriteButton())
            }
            .store(in: &cancellables)
        
        input.didTapWrite
            .withUnretained(self)
            .sink { (owner: ReviewBottomSheetViewModel, _) in
                if let _ = owner.config.review?.reviewId {
                    owner.editReview()
                } else {
                    owner.writeReview()
                }
                owner.sendClickWriteReview()
            }
            .store(in: &cancellables)
    }
    
    private func isEnableWriteButton() -> Bool {
        guard let _ = state.rating,
              let contents = state.contents else { return false }
        
        return contents.isNotEmpty
    }
    
    private func writeReview() {
        guard let rating = state.rating,
              let contents = state.contents else { return }
        
        Task {
            let input = WriteReviewRequestInput(
                storeId: config.storeId,
                contents: contents,
                rating: rating
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
    
    private func editReview() {
        guard let reviewId = config.review?.reviewId,
              let rating = state.rating,
              let contents = state.contents else { return }
        
        Task {
            let input = EditReviewRequestInput(contents: contents, rating: rating)
            let result = await storeService.editReview(reviewId: reviewId, input: input)
            
            switch result {
            case .success(let response):
                output.onSuccessEditReview.send(response)
                output.route.send(.dismiss)
                
            case .failure(let error):
                output.errorAlert.send(error)
            }
        }
    }
}

// MARK: Log
extension ReviewBottomSheetViewModel {
    private func sendClickWriteReview() {
        guard let rating = state.rating else { return }
        
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickReviewBottomButton,
            extraParameters: [
                .storeId: config.storeId,
                .rating: rating
            ]
        ))
    }
}
