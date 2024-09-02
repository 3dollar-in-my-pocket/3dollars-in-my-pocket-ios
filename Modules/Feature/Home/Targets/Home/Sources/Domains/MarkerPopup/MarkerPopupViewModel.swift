import Foundation
import Combine

import Common
import Model
import Networking
import Log

final class MarkerPopupViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let didTapButton = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .markerPopup
        let advertisement = PassthroughSubject<AdvertisementResponse, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case goToURL(String)
    }
    
    
    struct State {
        var advertisement: AdvertisementResponse?
    }
    
    let input = Input()
    let output = Output()
    private var state = State()
    private let advertisementRepository: AdvertisementRepository
    private let eventService: EventServiceProtocol
    private let logManager: LogManagerProtocol
    
    init(
        advertisementRepository: AdvertisementRepository = AdvertisementRepositoryImpl(),
        eventService: EventServiceProtocol = EventService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.advertisementRepository = advertisementRepository
        self.eventService = eventService
        self.logManager = logManager
        
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
                owner.sendClickEventLog()
            })
            .compactMap({ (owner: MarkerPopupViewModel, _) in
                owner.state.advertisement?.link?.url
            })
            .map { Route.goToURL($0) }
            .subscribe(output.route)
            .store(in: &cancellables)
    }
    
    private func fetchMarkerPopup() {
        Task {
            let input = FetchAdvertisementInput(position: .storeMarkerPopup, size: nil)
            let result = await advertisementRepository.fetchAdvertisements(input: input)
            
            switch result {
            case .success(let response):
                guard let advertisement = response.advertisements.first else { return }
                
                state.advertisement = advertisement
                output.advertisement.send(advertisement)
                
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func sendClickEvent() {
        guard let advertisementId = state.advertisement?.advertisementId else { return }
        
        Task {
            let _ = await eventService.sendClickEvent(targetId: advertisementId, type: "ADVERTISEMENT")
        }
    }
    
    private func sendClickEventLog() {
        guard let advertisementId = state.advertisement?.advertisementId else { return }
        
        logManager.sendEvent(LogEvent(
            screen: output.screenName,
            eventName: .clickBottomButton,
            extraParameters: [
                .advertisementId: advertisementId
            ]))
    }
}
