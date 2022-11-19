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
        case setIsEnableNextButton(Bool)
        case pushPolicy
        case pushMarketing
        case dismissAndGoHome
        case showLoading(Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var isCheckedAll: Bool
        var isCheckedPolicy: Bool
        var isCheckedMarketing: Bool
        var isEnableNextButton: Bool
        @Pulse var showErrorAlert: Error?
        @Pulse var pushPolicy: Void?
        @Pulse var pushMarketing: Void?
        @Pulse var isShowLoading: Bool?
        @Pulse var dismissAndGoHome: Void?
    }
    
    let initialState: State
    private let deviceService: DeviceServiceProtocol
    
    init(
        deviceService: DeviceServiceProtocol,
        state: State = State(
            isCheckedAll: false,
            isCheckedPolicy: false,
            isCheckedMarketing: false,
            isEnableNextButton: false
        )
    ) {
        self.initialState = state
        self.deviceService = deviceService
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
                self.registerPush(isMarketingOn: self.currentState.isCheckedMarketing),
                .just(.showLoading(false))
            ])
        }
    }
    
    private func registerPush(isMarketingOn: Bool) -> Observable<Mutation> {
        return self.deviceService.getFCMToken()
            .flatMap { [weak self] token -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
            }
        
        return self.deviceService.registerDevice(
            pushPlatformType: .fcm,
            pushSettings: isMarketingOn ? [.advertisement] : [],
            pushToken: <#T##String#>)
    }
}
