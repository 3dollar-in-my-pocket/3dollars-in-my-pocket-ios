import RxSwift
import ReactorKit

final class MyMedalReator: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case tapMedal(row: Int)
    }
    
    enum Mutation {
        case setCurrentMedal(Medal)
        case setMedals([Medal])
        case presentMedalInfo
        case showErrorAlert(Error)
    }
    
    struct State {
        var currentMedal: Medal
        var medals: [Medal]
        @Pulse var presentMedalInfo: ()?
    }
    
    let initialState: State
    private let userService: UserServiceProtocol
    private let medalService: MedalServiceProtocol
    private let metaContext: MetaContext
    private let globalState: GlobalState
    
    init(
        userService: UserServiceProtocol = UserService(),
        metaContext: MetaContext = .shared ,
        medalService: MedalServiceProtocol = MedalService(),
        globalState: GlobalState = .shared,
        state: State = State(currentMedal: Medal(), medals: [])
    ) {
        self.userService = userService
        self.medalService = medalService
        self.metaContext = metaContext
        self.globalState = globalState
        self.initialState = State(currentMedal: state.currentMedal, medals: metaContext.medals)
        
        super.init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.zip(self.fetchCurrentMedals(), self.fetchMyMedals())
                .flatMap { [weak self] currentMedal, myMedals -> Observable<Mutation> in
                    guard let self = self else { return .error(BaseError.unknown) }
                    
                    var medals = self.metaContext.medals
                    
                    for index in medals.indices {
                        medals[index].isOwned = myMedals.contains(medals[index])
                        
                        medals[index].isCurrentMedal
                        = medals[index].medalId == self.currentState.currentMedal.medalId
                    }
                    
                    return .merge([
                        .just(.setMedals(medals)),
                        .just(.setCurrentMedal(currentMedal))
                    ])
                }
                .catch { .just(.showErrorAlert($0)) }
            
        case .tapMedal(let row):
            let tappedMedal = self.currentState.medals[row]
            
            if tappedMedal.isOwned {
                return self.changeMyMedal(medalId: tappedMedal.medalId)
            } else {
                return .just(.presentMedalInfo)
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setCurrentMedal(let medal):
            newState.currentMedal = medal
            
            for index in newState.medals.indices {
                newState.medals[index].isCurrentMedal
                = newState.medals[index].medalId == medal.medalId
            }
            
        case .setMedals(let medals):
            newState.medals = medals
            
        case .presentMedalInfo:
            newState.presentMedalInfo = ()
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func fetchMyMedals() -> Observable<[Medal]> {
        return self.medalService.fetchMyMedals()
    }
    
    private func fetchCurrentMedals() -> Observable<Medal> {
        return self.userService.fetchUserActivity()
            .map { $0.medal }
    }
    
    private func changeMyMedal(medalId: Int) -> Observable<Mutation> {
        return self.medalService.changeMyMedal(medalId: medalId)
            .do(onNext: { [weak self] user in
                self?.globalState.updateMedal.onNext(user.medal)
            })
            .map { .setCurrentMedal($0.medal) }
            .catch { .just(.showErrorAlert($0)) }
    }
}
