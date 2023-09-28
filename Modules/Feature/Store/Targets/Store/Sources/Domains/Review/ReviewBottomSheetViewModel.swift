import UIKit
import Combine

import Common
import DesignSystem
import Model
import Networking

final class ReviewBottomSheetViewModel: BaseViewModel {
    struct Input {
        let didTapRating = PassthroughSubject<Int, Never>()
        let inputReview = PassthroughSubject<String, Never>()
        let didTapWrite = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let rating: CurrentValueSubject<Int?, Never>
        let contents: CurrentValueSubject<String?, Never>
        let isEnableWriteButton: CurrentValueSubject<Bool, Never>
        let onSuccessWriteReview = PassthroughSubject<StoreDetailReview, Never>()
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
        let rating: Int? = nil
        let contents: String? = nil
    }
    
    let input = Input()
    let output: Output
    private let storeService: StoreServiceProtocol
    private let config: Config
    private var state: State
    
    init(config: Config, storeService: StoreServiceProtocol = StoreService()) {
        self.config = config
        self.storeService = storeService
        
        let isEnableWriteButton = (config.contents != nil) && (config.rating != nil)
        self.output = Output(
            rating: .init(config.rating),
            contents: .init(config.contents),
            isEnableWriteButton: .init(isEnableWriteButton)
        )
        self.state = State(rating: config.rating, contents: config.contents)
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
                owner.writeReview()
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
}
