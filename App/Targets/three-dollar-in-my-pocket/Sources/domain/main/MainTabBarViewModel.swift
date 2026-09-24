import Foundation
import Combine

import Common
import Log
import Networking
import Model

final class MainTabBarViewModel: Common.BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let didTapTab = PassthroughSubject<TabBarTag, Never>()
    }
    
    struct Output {
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case presentMainBannerPopup(MainBannerPopupViewModel)
    }
    
    struct Dependency {
        let advertisementRepository: AdvertisementRepository
        var preference: Preference
        let deeplinkHandler: DeepLinkHandler
        let logManager: LogManagerProtocol

        init(
            advertisementRepository: AdvertisementRepository = AdvertisementRepositoryImpl(),
            preference: Preference = .shared,
            deeplinkHandler: DeepLinkHandler = .shared,
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.advertisementRepository = advertisementRepository
            self.preference = preference
            self.deeplinkHandler = deeplinkHandler
            self.logManager = logManager
        }
    }
    
    let input = Input()
    let output = Output()
    private var dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: MainTabBarViewModel, _) in
                owner.checkIfBannerExisted()
            }
            .store(in: &cancellables)

        input.didTapTab
            .withUnretained(self)
            .sink { (owner: MainTabBarViewModel, tab: TabBarTag) in
                owner.sendTabClickLog(tab)
            }
            .store(in: &cancellables)
    }

    private func sendTabClickLog(_ tab: TabBarTag) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: .mainTabBar,
            objectType: .tab,
            objectId: tab.logObjectId
        ))
    }
    
    private func checkIfBannerExisted() {
        Task {
            let input = FetchAdvertisementInput(position: .splash, size: nil)
            let result = await dependency.advertisementRepository.fetchAdvertisements(input: input)
            
            switch result {
            case .success(let response):
                guard let advertisement = response.advertisements.first,
                      dependency.deeplinkHandler.reservedDeepLinkExisted().isNot else { return }
                presentMainAdBannerIfNeeded(advertisement)
                
            case .failure:
                break
            }
        }
    }
    
    private func presentMainAdBannerIfNeeded(_ advertisement: AdvertisementResponse) {
        let config = MainBannerPopupViewModel.Config(advertisement: advertisement)
        let viewModel = MainBannerPopupViewModel(config: config)
        
        if let shownDate = dependency.preference.getShownMainBannerDate(id: advertisement.advertisementId) {
            if shownDate != Common.DateUtils.todayString() {
                output.route.send(.presentMainBannerPopup(viewModel))
            }
        } else {
            output.route.send(.presentMainBannerPopup(viewModel))
        }
    }
}
