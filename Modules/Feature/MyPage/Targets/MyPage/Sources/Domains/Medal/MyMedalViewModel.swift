import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class MyMedalViewModel: BaseViewModel {
    struct Input {
        let loadTrigger = PassthroughSubject<Void, Never>()
        let didSelectInfoButton = PassthroughSubject<Void, Never>()
        let didSelectCurrentMedal = PassthroughSubject<Void, Never>()
        let didSelectMedal = PassthroughSubject<Medal, Never>()
    }

    struct Output {
        let screen: ScreenName = .myMedal
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let sections = CurrentValueSubject<[MyMedalSection], Never>([])
    }

    struct State {
        var medals: [Medal] = []
        var representativeMedal = Medal()
        var ownedMedals: [Medal] = []
        var userNickname = ""
    }

    enum Route {
        case medalInfo(MedalInfoViewModel)
    }

    let input = Input()
    let output = Output()

    private var state = State()

    private let medalService: MedalServiceProtocol
    private let userService: UserServiceProtocol
    private let userDefaults: UserDefaultsUtil
    private let logManager: LogManagerProtocol

    init(
        medalService: MedalServiceProtocol = MedalService(),
        userService: UserServiceProtocol = UserService(),
        userDefaults: UserDefaultsUtil = .shared,
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.medalService = medalService 
        self.userService = userService
        self.userDefaults = userDefaults
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()
        
        input.loadTrigger
            .withUnretained(self)
            .sink { (owner: MyMedalViewModel, _) in
                owner.fetchUserAndMedals()
            }
            .store(in: &cancellables)
        
        input.didSelectMedal
            .removeDuplicates()
            .filter { [weak self] in $0.medalId != self?.state.representativeMedal.medalId }
            .withUnretained(self)
            .handleEvents(receiveOutput: { (owner: MyMedalViewModel, medal: Medal) in
                owner.sendClickMedal(medal)
                owner.state.representativeMedal = medal
            })
            .asyncMap { (owner: MyMedalViewModel, medal: Medal) in
                await owner.userService.editUser(
                    nickname: owner.state.userNickname,
                    representativeMedalId: medal.medalId
                )
            }
            .withUnretained(self)
            .sink { owner, result in
                switch result {
                case .success:
                    owner.state.medals = owner.state.medals.map { medal in
                        var medal = medal
                        medal.isCurrentMedal = owner.state.representativeMedal.medalId == medal.medalId
                        return medal
                    }
                    owner.updateDataSource()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
        
        input.didSelectInfoButton
            .merge(with: input.didSelectCurrentMedal)
            .withUnretained(self)
            .map { owner, _ in .medalInfo(owner.bindMedalInfoViewModel()) }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
    
    private func fetchUserAndMedals() {
        Task {
            output.showLoading.send(true)
            let medalResponse = await medalService.fetchMedals()
            let userResponse = await userService.fetchUser()
            output.showLoading.send(false)
            
            if let medals = medalResponse.data,
               let user = userResponse.data {
                state.medals = medals.map { medal in
                    Medal(
                        response: medal,
                        isOwned: user.ownedMedals.contains(where: { $0.medalId == medal.medalId }),
                        isCurrentMedal: user.representativeMedal.medalId == medal.medalId
                    )
                }
                
                state.representativeMedal = Medal(response: user.representativeMedal)
                state.ownedMedals = user.ownedMedals.map(Medal.init(response:))
                state.userNickname = user.name
                updateDataSource()
            } else {
                if let medalError = medalResponse.error {
                    output.showErrorAlert.send(medalError)
                }
            }
        }
        .store(in: taskBag)
    }
    
    private func updateDataSource() {
        let representativeMedal = state.representativeMedal
        let totalMedals = state.medals
            
        // 정렬 필요한지 확인
//            .sorted {
//            if $0.isCurrentMedal == $1.isCurrentMedal {
//                return $0.isOwned && !$1.isOwned
//            } else {
//                return $0.isCurrentMedal && !$1.isCurrentMedal
//            }
//            // Date 비교 추가
//        }
//     
        var sections: [MyMedalSection] = []
        sections.append(MyMedalSection(type: .currentMedal, items: [.currentMedal(representativeMedal)]))
        sections.append(MyMedalSection(type: .medal, items: totalMedals.map { .medal($0) }))
        output.sections.send(sections)
    }
    
    private func bindMedalInfoViewModel() -> MedalInfoViewModel {
        let config = MedalInfoViewModel.Config(medals: state.medals)
        let viewModel = MedalInfoViewModel(config: config)
        return viewModel
    }
}

private extension MyMedalViewModel {
    func sendClickMedal(_ medal: Medal) {
        guard let medalId = medal.medalId else { return }
        logManager.sendEvent(.init(screen: output.screen, eventName: .clickMedal, extraParameters: [
            .medalId: medalId
        ]))
    }
}
