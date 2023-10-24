import Foundation
import Combine

import Common
import Model
import Networking

final class MarkerPopupViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let didTapButton = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let advertisement = PassthroughSubject<Advertisement, Never>()
        let showErrorAloer = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case goToURL(String)
    }
    
    
    struct State {
        var advertisement: Advertisement?
    }
    
    let input = Input()
    let output = Output()
    private var state = State()
    private let advertisementService: AdvertisementServiceProtocol
    private let eventService: EventServiceProtocol
    
    init(
        advertisementService: AdvertisementServiceProtocol = AdvertisementService(),
        eventService: EventServiceProtocol = EventService()
    ) {
        self.advertisementService = advertisementService
        self.eventService = eventService
        
        super.init()
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: MarkerPopupViewModel, _) in
                <#code#>
            }
            .store(in: &cancellables)
    }
    
    private func 
}
