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
    private let medalService: MedalServiceProtocol
    private let metaContext: MetaContext
    private let globalState: GlobalState
    
    init(
        medal: Medal,
        metaContext: MetaContext,
        medalService: MedalServiceProtocol,
        globalState: GlobalState,
        state: State = State(currentMedal: Medal(), medals: [])
    ) {
        self.medalService = medalService
        self.metaContext = metaContext
        self.globalState = globalState
        self.initialState = State(currentMedal: medal, medals: metaContext.medals)
        
        super.init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.fetchMyMedals()
            
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
    
    private func fetchMyMedals() -> Observable<Mutation> {
        return self.medalService.fetchMyMedals()
            .flatMap { [weak self] myMedals -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                var medals = self.metaContext.medals

                for index in medals.indices {
                    medals[index].isOwned = myMedals.contains(medals[index])
                    
                    medals[index].isCurrentMedal
                    = medals[index].medalId == self.currentState.currentMedal.medalId
                }
                
                return .just(.setMedals(medals))
            }
            .catch { .just(.showErrorAlert($0)) }
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
