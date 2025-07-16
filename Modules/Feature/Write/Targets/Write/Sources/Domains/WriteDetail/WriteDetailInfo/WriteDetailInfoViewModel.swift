import Combine

import Common
import Model

extension WriteDetailInfoViewModel {
    struct Input {
        let storeName = PassthroughSubject<String, Never>()
        let selectStoreType = PassthroughSubject<UserStoreCreateRequest.StoreType, Never>()
        let didTapChangeAddress = PassthroughSubject<Void, Never>()
        let didTapNext = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let storeName: CurrentValueSubject<String, Never>
        let storeTypes: CurrentValueSubject<UserStoreCreateRequest.StoreType, Never>
        let address: String
        let setErrorState = PassthroughSubject<Void, Never>()
        let finishWriteDetailInfo = PassthroughSubject<(storeName: String, storeType: UserStoreCreateRequest.StoreType), Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pop
        case showErrorAelrt(Error)
        case showToast(String)
    }
    
    private struct State {
        var storeName: String
        var storeType: UserStoreCreateRequest.StoreType
        var address: String
    }
    
    struct Config {
        let address: String
        let storeName: String = ""
        let storeTypes: UserStoreCreateRequest.StoreType = .road
    }
}


final class WriteDetailInfoViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    
    init(config: Config) {
        self.output = Output(
            storeName: .init(config.storeName),
            storeTypes: .init(config.storeTypes),
            address: config.address
        )
        self.state = State(
            storeName: config.storeName,
            storeType: config.storeTypes,
            address: config.address
        )
        
        super.init()
    }
    
    override func bind() {
        input.storeName
            .sink { [weak self] name in
                self?.state.storeName = name
            }
            .store(in: &cancellables)
        
        input.selectStoreType
            .sink { [weak self] type in
                self?.state.storeType = type
            }
            .store(in: &cancellables)
        
        input.didTapChangeAddress
            .sink { [weak self] in
                self?.output.route.send(.pop)
            }
            .store(in: &cancellables)
        
        input.didTapNext
            .sink { [weak self] in
                guard let self else { return }
                
                guard state.storeName.isNotEmpty else {
                    output.route.send(.showToast(Strings.WriteDetailInfo.Toast.needStoreName))
                    output.setErrorState.send(())
                    return
                }
                
                output.finishWriteDetailInfo.send((state.storeName, state.storeType))
            }
            .store(in: &cancellables)
    }
}
