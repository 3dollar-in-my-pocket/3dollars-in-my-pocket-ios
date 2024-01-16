import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class MyMedalViewModel: BaseViewModel {
    struct Config {
        let representativeMedal: Medal
        let ownedMedals: [Medal]
    }
    
    struct Input {
        let loadTrigger = PassthroughSubject<Void, Never>()
        let didSelectItem = PassthroughSubject<IndexPath, Never>()
        let didSelectInfoButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let sections = CurrentValueSubject<[MyMedalSection], Never>([])
    }

    struct State {
        var medals: [Medal] = []
    }

    enum Route {
        case medalInfo(MedalInfoViewModel)
    }

    let input = Input()
    let output = Output()

    private var state = State()
    
    private let config: Config

    private let medalService: MedalServiceProtocol
    private let userDefaults: UserDefaultsUtil
    private let logManager: LogManagerProtocol

    init(
        config: Config,
        medalService: MedalServiceProtocol = MedalService(),
        userDefaults: UserDefaultsUtil = .shared,
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.config = config
        self.medalService = medalService 
        self.userDefaults = userDefaults
        self.logManager = logManager

        super.init()
    }

    override func bind() {
        super.bind()
        
        input.loadTrigger
            .withUnretained(self)
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .withUnretained(self)
            .asyncMap { owner, _ in
                await owner.medalService.fetchMedals()
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                switch result {
                case .success(let response):
                    owner.state.medals = response.map { medal in
                        Medal(
                            response: medal, 
                            isOwned: owner.config.ownedMedals.contains(where: { $0.medalId == medal.medalId }), 
                            isCurrentMedal: owner.config.representativeMedal.medalId == medal.medalId
                        ) 
                    }
                    owner.updateDataSource()
                case .failure(let error):
                    owner.output.showErrorAlert.send(error)
                }
            }
            .store(in: &cancellables)
        
        input.didSelectItem.mapVoid
            .merge(with: input.didSelectInfoButton)
            .withUnretained(self)
            .map { owner, _ in .medalInfo(owner.bindMedalInfoViewModel()) }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
    
    private func updateDataSource() {
        let representativeMedal = config.representativeMedal
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
