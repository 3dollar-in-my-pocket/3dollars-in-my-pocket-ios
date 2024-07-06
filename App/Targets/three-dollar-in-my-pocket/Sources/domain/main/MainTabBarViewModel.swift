import UIKit
import Combine

import Common
import Networking
import Model

final class MainTabBarViewModel: Common.BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case presentMainBannerPopup(MainBannerPopupViewModel)
    }
    
    let input = Input()
    let output = Output()
    private let advertisementService: Networking.AdvertisementServiceProtocol
    private var preference = Preference.shared
    
    init(advertisementService: Networking.AdvertisementServiceProtocol = Networking.AdvertisementService()) {
        self.advertisementService = advertisementService
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: MainTabBarViewModel, _) in
                owner.checkIfBannerExisted()
            }
            .store(in: &cancellables)
    }
    
    private func checkIfBannerExisted() {
        Task {
            let input = FetchAdvertisementInput(position: .splash, size: nil)
            let result = await advertisementService.fetchAdvertisements(input: input)
            
            switch result {
            case .success(let advertisements):
                guard let advertisementResponse = advertisements.first else { return }
                let advertisement = Model.Advertisement(response: advertisementResponse)
                
                presentMainAdBannerIfNeeded(advertisement)
                
            case .failure:
                break
            }
        }
    }
    
    private func presentMainAdBannerIfNeeded(_ advertisement: Model.Advertisement) {
        let config = MainBannerPopupViewModel.Config(advertisement: advertisement)
        let viewModel = MainBannerPopupViewModel(config: config)
        
        if let shownDate = preference.getShownMainBannerDate(id: advertisement.advertisementId) {
            if shownDate != Common.DateUtils.todayString() {
                output.route.send(.presentMainBannerPopup(viewModel))
            }
        } else {
            output.route.send(.presentMainBannerPopup(viewModel))
        }
    }
}
