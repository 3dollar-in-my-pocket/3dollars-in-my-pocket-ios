import Base
import RxSwift
import ReactorKit
import RxCocoa

final class BossStoreFeedbackReactor: BaseReactor, Reactor {
    enum Action {
        case selectFeedback(index: Int)
        case deselectFeedback(index: Int)
        case tapSendFeedback
    }
    
    enum Mutation {
        case selectFeedback(index: Int)
        case deSelectFeedback(index: Int)
        case pop
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
        case showToast(String)
    }
    
    struct State {
        var feedbackTypes: [BossStoreFeedbackMeta]
        var selectedIndex: [Int]
        var isEnableSendFeedbackButton: Bool
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
            selectedIndex: [],
            isEnableSendFeedbackButton: false
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectFeedback(let index):
            return .just(.selectFeedback(index: index))
            
        case .deselectFeedback(let index):
            return .just(.deSelectFeedback(index: index))
            
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
        case .selectFeedback(let index):
            newState.selectedIndex.append(index)
            newState.isEnableSendFeedbackButton = !newState.selectedIndex.isEmpty
            
        case .deSelectFeedback(let index):
            if let targetIndex = newState.selectedIndex.firstIndex(of: index) {
                newState.selectedIndex.remove(at: targetIndex)
            }
            newState.isEnableSendFeedbackButton = !newState.selectedIndex.isEmpty
            
        case .pop:
            self.popPublisher.accept(())
            
        case .showLoading(let isShow):
            self.showLoadingPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
            
        case .showToast(let message):
            self.showToastPublisher.accept(message)
        }
        
        return newState
    }
    
    private func sendFeedback(
        bossStoreId: String,
        selectedFeedbakcs: [BossStoreFeedbackType]
    ) -> Observable<Mutation> {
        return self.feedbackService.sendFeedbacks(
            storeType: .foodTruck,
            bossStoreId: bossStoreId,
            feedbackTypes: selectedFeedbakcs
        )
        .flatMap { [weak self] _ -> Observable<Mutation> in
            guard let self = self else { return .error(BaseError.unknown) }
            
            return self.fetchFeedbacks(bossStoreId: self.bossStoreId)
        }
        .catch { .just(.showErrorAlert($0)) }
    }
    
    private func fetchFeedbacks(bossStoreId: String) -> Observable<Mutation> {
        return self.feedbackService.fetchBossStoreFeedbacks(
            storeType: .foodTruck,
            bossStoreId: self.bossStoreId
        )
        .do(onNext: { [weak self] feedbacks in
            self?.globalState.updateFeedbacks.onNext(feedbacks)
        })
        .flatMap { _ -> Observable<Mutation> in
            return .merge([
                .just(.pop),
                .just(.showToast(
                    R.string.localization.boss_store_feedback_send_feedback()
                ))
            ])
        }
        .catch { .just(.showErrorAlert($0)) }
    }
}
