import ReactorKit

final class PolicyReactor: Reactor {
    enum Action {
        case tapAllCheckButton
        case tapPolicyCheck
        case tapMarketingCheck
        case tapNext
    }
    
    enum Mutation {
        case toggleAll
        case togglePolicy
        case toggleMarketing
        case dismiss
        case showLoading(Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var isCheckedAll: Bool
        var isCheckedPolicy: Bool
        var isCheckedMarketing: Bool
        var isEnableNextButton: Bool
        @Pulse var showErrorAlert: Error?
        @Pulse var isShowLoading: Bool?
        @Pulse var dismiss: Void?
    }
    
    let initialState: State
    private let userService: UserServiceProtocol
    private let analyticsManager: AnalyticsManagerProtocol
    
    init(
        userService: UserServiceProtocol,
        analyticsManager: AnalyticsManagerProtocol,
        state: State = State(
            isCheckedAll: false,
            isCheckedPolicy: false,
            isCheckedMarketing: false,
            isEnableNextButton: false
        )
    ) {
        self.initialState = state
        self.userService = userService
        self.analyticsManager = analyticsManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapAllCheckButton:
            return .just(.toggleAll)
            
        case .tapPolicyCheck:
            return .just(.togglePolicy)
            
        case .tapMarketingCheck:
            return .just(.toggleMarketing)
            
        case .tapNext:
            return .concat([
                .just(.showLoading(true)),
                self.changeMarketingConsent(isMarketingOn: self.currentState.isCheckedMarketing),
                .just(.showLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .toggleAll:
            newState.isCheckedAll.toggle()
            newState.isCheckedPolicy = newState.isCheckedAll
            newState.isCheckedMarketing = newState.isCheckedAll
            newState.isEnableNextButton = newState.isCheckedPolicy
            
        case .togglePolicy:
            newState.isCheckedPolicy.toggle()
            newState.isEnableNextButton = newState.isCheckedPolicy
            
        case .toggleMarketing:
            newState.isCheckedMarketing.toggle()
            
        case .dismiss:
            newState.dismiss = ()
            
        case .showLoading(let isShow):
            newState.isShowLoading = isShow
            
        case .showErrorAlert(let error):
            newState.showErrorAlert = error
        }
        
        return newState
    }
    
    private func changeMarketingConsent(isMarketingOn: Bool) -> Observable<Mutation> {
        return self.userService.changeMarketingConsent(
            marketingConsentType: isMarketingOn ? .approve : .deny
        )
        .do(onNext: { [weak self] _ in
            self?.analyticsManager.setPushEnable(isEnable: isMarketingOn)
        })
        .map { _ in .dismiss }
        .catch {. just(.showErrorAlert($0)) }
    }
}
