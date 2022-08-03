import Base
import RxSwift
import ReactorKit
import RxCocoa

final class BossStoreFeedbackReactor: BaseReactor, Reactor {
    enum Action {
        case selectFeedback(index: Int)
        case tapSendFeedback
    }
    
    enum Mutation {
        case toggleFeedback(index: Int)
        case pop
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var feedbackTypes: [BossStoreFeedbackMeta]
        var selectedIndex: [Int]
    }
    
    let initialState: State
    let popPublisher = PublishRelay<Void>()
    private let bossStoreId: String
    private let feedbackService: FeedbackServiceProtocol
    private let globalState: GlobalState
    private let metaContext: MetaContext
    
    init(
        bossStoreId: String,
        feedbackService: FeedbackServiceProtocol,
        globalState: GlobalState,
        metaContext: MetaContext
    ) {
        self.bossStoreId = bossStoreId
        self.feedbackService = feedbackService
        self.globalState = globalState
        self.metaContext = metaContext
        self.initialState = State(
            feedbackTypes: metaContext.feedbackTypes,
            selectedIndex: []
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectFeedback(let index):
            return .just(.toggleFeedback(index: index))
            
        case .tapSendFeedback:
            let selectedFeedbacks = self.currentState.selectedIndex.map {
                self.currentState.feedbackTypes[$0].feedbackType
            }
            
            return .concat([
                .just(.showLoading(isShow: true)),
                self.sendFeedback(
                    bossStoreId: self.bossStoreId,
                    selectedFeedbakcs: selectedFeedbacks
                ),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .toggleFeedback(let index):
            if let targetIndex = newState.selectedIndex.firstIndex(of: index) {
                newState.selectedIndex.remove(at: targetIndex)
            } else {
                newState.selectedIndex.append(index)
            }
            
        case .pop:
            self.popPublisher.accept(())
            
        case .showLoading(let isShow):
            self.showLoadingPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func sendFeedback(
        bossStoreId: String,
        selectedFeedbakcs: [BossStoreFeedbackType]
    ) -> Observable<Mutation> {
        return self.feedbackService.sendFeedbacks(
            bossStoreId: bossStoreId,
            feedbackTypes: selectedFeedbakcs
        )
        .map { .pop }
        .catch { .just(.showErrorAlert($0)) }
    }
}
