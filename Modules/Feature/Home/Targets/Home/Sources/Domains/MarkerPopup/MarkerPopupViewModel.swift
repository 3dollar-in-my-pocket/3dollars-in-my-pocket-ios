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
                owner.fetchMarkerPopup()
            }
            .store(in: &cancellables)
        
        input.didTapButton
            .withUnretained(self)
            .handleEvents(receiveOutput: { (owner: MarkerPopupViewModel, _) in
                owner.sendClickEvent()
            })
            .compactMap({ (owner: MarkerPopupViewModel, _) in
                owner.state.advertisement?.linkUrl
            })
            .map { Route.goToURL($0) }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
    
    private func fetchMarkerPopup() {
        Task {
            let input = FetchAdvertisementInput(position: .storeMarkerPopup, size: nil)
            let result = await advertisementService.fetchAdvertisements(input: input)
            
            switch result {
            case .success(let response):
                guard let advertisementResponse = response.first else { return }
                let advertisement = Advertisement(response: advertisementResponse)
                
                output.advertisement.send(advertisement)
                
            case .failure(let error):
                output.showErrorAloer.send(error)
            }
        }
    }
    
    private func sendClickEvent() {
        guard let advertisementId = state.advertisement?.advertisementId else { return }
        
        Task {
            let _ = await eventService.sendClickEvent(targetId: advertisementId, type: "ADVERTISEMENT")
        }
    }
}
