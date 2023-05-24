import Foundation
import Combine

final class WriteAddressViewModel {
    struct Input {
        let moveCamera = PassthroughSubject<Location, Never>()
        let tapCurrentLocation = PassthroughSubject<Void, Never>()
        let tapSetAddress = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let setNearStores = PassthroughSubject<[Store], Never>()
        let moveCamera = PassthroughSubject<Location, Never>()
        let setAddress = PassthroughSubject<String, Never>()
        let error = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pushAddressDetail(address: String, location: Location)
        case presentConfirmPopup(address: String)
    }
    
    private struct State {
        var address = ""
        var nearStores: [Store] = []
        var cameraPosition: Location?
    }
    
    let input = Input()
    let output = Output()
    
    
    init() {
        
    }
}
