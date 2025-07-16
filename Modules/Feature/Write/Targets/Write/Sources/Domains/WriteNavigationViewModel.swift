import Combine
import CoreLocation

import Common
import Model

extension WriteNavigationViewModel {
    struct Input {
        let finishWriteAddress = PassthroughSubject<(address: String, location: CLLocation), Never>()
        let finishWriteDetailInfo = PassthroughSubject<(storeName: String, storeType: UserStoreCreateRequest.StoreType), Never>()
    }
    
    struct Output {
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pushWriteDetailInfo(WriteDetailInfoViewModel)
    }
    
    private struct State {
        var location: CLLocation?
        var address: String?
        var storeName: String?
        var storeType: UserStoreCreateRequest.StoreType?
    }
}

final class WriteNavigationViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    
    override func bind() {
        input.finishWriteAddress
            .sink { [weak self] (address: String, location: CLLocation) in
                self?.state.address = address
                self?.state.location = location
                self?.pushWriteDetailInfo()
            }
            .store(in: &cancellables)
        
        input.finishWriteDetailInfo
            .sink { [weak self] (storeName: String, storeType: UserStoreCreateRequest.StoreType) in
                self?.state.storeName = storeName
                self?.state.storeType = storeType
                self?.pushWriteDetailCategory()
            }
            .store(in: &cancellables)
    }

    private func pushWriteDetailInfo() {
        guard let address = state.address else { return }
        let config = WriteDetailInfoViewModel.Config(address: address)
        let viewModel = WriteDetailInfoViewModel(config: config)
        
        viewModel.output.finishWriteDetailInfo
            .subscribe(input.finishWriteDetailInfo)
            .store(in: &viewModel.cancellables)
        output.route.send(.pushWriteDetailInfo(viewModel))
    }
    
    private func pushWriteDetailCategory() {
        
    }
}
