import ReactorKit
import RxSwift
import RxCocoa

final class ReviewModalReactor: BaseReactor, Reactor {
    enum Action {
        case onTapRating(rating: Int)
        case inputReview(String)
        case tapRegisterButton
    }
    
    enum Mutation {
        case setRating(Int)
        case setContents(String)
        case dismiss
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        @Pulse var dismiss: Void
        var review: Review
    }
    
    let initialState: State
    private let reviewService: ReviewServiceProtocol
    private let globalState: GlobalState
    
    init(
        storeId: Int,
        review: Review? = nil,
        reviewService: ReviewServiceProtocol,
        globalState: GlobalState
    ) {
        self.reviewService = reviewService
        self.globalState = globalState
        if let review = review {
            self.initialState = State(dismiss: (), review: review)
        } else {
            self.initialState = State(dismiss: (), review: Review(store: Store(id: storeId)))
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .onTapRating(let rating):
            return .just(.setRating(rating))
            
        case .inputReview(let input):
            return .just(.setContents(input))
            
        case .tapRegisterButton:
            guard self.isValidateReview(text: self.currentState.review.contents) else {
                return .just(.showErrorAlert(BaseError.custom("내용을 입력해주세요.")))
            }
            
            if self.currentState.review.isNewReview {
                return .concat([
                    .just(.showLoading(isShow: true)),
                    self.saveReview(review: self.currentState.review),
                    .just(.showLoading(isShow: false))
                ])
            } else {
                return .concat([
                    .just(.showLoading(isShow: true)),
                    self.modeifyReview(review: self.currentState.review),
                    .just(.showLoading(isShow: false))
                ])
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setRating(let rating):
            newState.review.rating = rating
            
        case .setContents(let contents):
            newState.review.contents = contents
            
        case .dismiss:
            newState.dismiss = ()
            
        case .showLoading(let isShow):
            self.showLoadingPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func modeifyReview(review: Review) -> Observable<Mutation> {
        return self.reviewService.modifyReview(review: review)
            .do(onNext: { [weak self] review in
                // TODO: 리뷰 추가로 변경 필요
                self?.globalState.updateStore.onNext(Store())
            })
            .map { _ in .dismiss }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func saveReview(review: Review) -> Observable<Mutation> {
        return self.reviewService.saveReview(review: review)
            .do(onNext: { [weak self] review in
                // TODO: 리뷰 추가로 변경 필요
                self?.globalState.updateStore.onNext(Store())
            })
            .map { _ in .dismiss }
            .catch { .just(.showErrorAlert($0)) }
    }
    
    private func isValidateReview(text: String) -> Bool {
        guard text != "review_modal_placeholder".localized else { return false }
        
        return !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
