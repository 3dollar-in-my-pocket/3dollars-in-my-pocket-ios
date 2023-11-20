import Foundation
import Combine

import Common
import Networking
import Model

final class SearchAddressViewModel: BaseViewModel {
    struct Input {
        let inputKeyword = PassthroughSubject<String, Never>()
        let didTapAddress = PassthroughSubject<Int, Never>()
        let didScroll = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let sections = PassthroughSubject<[SearchAddressSection], Never>()
        let isHiddenClear = PassthroughSubject<Bool, Never>()
        let hideKeyboard = PassthroughSubject<Void, Never>()
        let selectAddress = PassthroughSubject<PlaceDocument, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }
    
    struct State {
        var address: [PlaceDocument] = []
    }
    
    enum Route {
        case dismiss
    }
    
    let input = Input()
    let output = Output()
    private var state = State()
    private let mapService: MapServiceProtocol
    
    init(mapService: MapServiceProtocol = MapService()) {
        self.mapService = mapService
        super.init()
    }
    
    override func bind() {
        input.inputKeyword
            .filter { !$0.isEmpty }
            .throttle(for: 0.5, scheduler: RunLoop.current, latest: true)
            .withUnretained(self)
            .sink(receiveValue: { (owner: SearchAddressViewModel, keyword: String) in
                owner.searchAddress(keyword: keyword)
            })
            .store(in: &cancellables)
        
        input.inputKeyword
            .map { $0.isEmpty }
            .subscribe(output.isHiddenClear)
            .store(in: &cancellables)
        
        input.didTapAddress
            .withUnretained(self)
            .sink(receiveValue: { (owner: SearchAddressViewModel, index: Int) in
                guard let selectedAddress = owner.state.address[safe: index] else { return }
                
                owner.selectAddress(document: selectedAddress)
            })
            .store(in: &cancellables)
        
        input.didScroll
            .mapVoid
            .subscribe(output.hideKeyboard)
            .store(in: &cancellables)
    }
    
    private func searchAddress(keyword: String) {
        Task {
            let result = await mapService.searchAddress(keyword: keyword)
            
            switch result {
            case .success(let response):
                state.address = response.documents
                
                let sectionItems: [SearchAddressSectionItem] = response.documents.map { .address($0) }
                output.sections.send([.init(items: sectionItems)])
                
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func selectAddress(document: PlaceDocument) {
        output.selectAddress.send(document)
        output.route.send(.dismiss)
    }
}
