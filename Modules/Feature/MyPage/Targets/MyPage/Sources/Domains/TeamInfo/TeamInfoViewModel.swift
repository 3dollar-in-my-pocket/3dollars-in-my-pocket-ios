import Combine

import Common
import Model
import Networking
import Log

extension TeamInfoViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let screenName: ScreenName = .teamInfo
        let creatorGroups = PassthroughSubject<[CreatorGroupResponse], Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    enum Route {
        case showErrorAlert(Error)
    }

    struct Dependency {
        let serviceCreatorRepository: ServiceCreatorRepository

        init(serviceCreatorRepository: ServiceCreatorRepository = ServiceCreatorRepositoryImpl()) {
            self.serviceCreatorRepository = serviceCreatorRepository
        }
    }
}

final class TeamInfoViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let dependency: Dependency

    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        super.init()
    }

    override func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: TeamInfoViewModel, _) in
                owner.fetchCreators()
            }
            .store(in: &cancellables)
    }

    private func fetchCreators() {
        Task { [weak self] in
            guard let self else { return }
            let result = await dependency.serviceCreatorRepository.listCreators()

            switch result {
            case .success(let response):
                output.creatorGroups.send(response.contents.filter { $0.creatorNames.isNotEmpty })
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
        .store(in: taskBag)
    }
}
