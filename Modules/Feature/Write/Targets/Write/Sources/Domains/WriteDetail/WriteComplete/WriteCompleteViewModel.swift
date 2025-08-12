import Foundation
import Combine

import Common
import Model

extension WriteCompleteViewModel {
    struct Input {
        let didTapAddMenu = PassthroughSubject<Void, Never>()
        let didTapAddAdditionalInfo = PassthroughSubject<Void, Never>()
        let didTapComplete = PassthroughSubject<Void, Never>()
        let updateStore = PassthroughSubject<UserStoreResponse, Never>()
    }
    
    struct Output {
        let userStoreResponse: CurrentValueSubject<UserStoreResponse, Never>
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pushWriteDetailMenu(WriteDetailMenuViewModel)
        case pushWriteDetailAdditionalInfo(WriteDetailAdditionalInfoViewModel)
        case dismiss
    }
    
    struct State {
        var userStoreResponse: UserStoreResponse
    }
    
    struct Config {
        let userStoreResponse: UserStoreResponse
    }
}

final class WriteCompleteViewModel: BaseViewModel {
    let input = Input()
    let output: Output

    private var state: State
    
    init(config: Config) {
        self.output = Output(userStoreResponse: .init(config.userStoreResponse))
        self.state = State(userStoreResponse: config.userStoreResponse)
        super.init()
    }
    
    override func bind() {
        input.didTapAddMenu
            .sink { [weak self] in
                self?.pushWriteDetailMenu()
            }
            .store(in: &cancellables)
        
        input.didTapAddAdditionalInfo
            .sink { [weak self] in
                self?.pushWriteDetailAdditionalInfo()
            }
            .store(in: &cancellables)
        
        input.didTapComplete
            .sink { [weak self] in
                self?.handleCompleteTap()
            }
            .store(in: &cancellables)
        
        input.updateStore
            .sink { [weak self] userStoreResponse in
                self?.state.userStoreResponse = userStoreResponse
                self?.output.userStoreResponse.send(userStoreResponse)
            }
            .store(in: &cancellables)
    }
    
    private func pushWriteDetailMenu() {
//        let config = WriteDetailMenuViewModel.Config(
//            categories: [], // TODO: 여기 수정 필요.(해당 화면 자체적으로 카테고리 패치 해야할 듯)
//            selectedCategories: state.storeCreateResponse.categoriesV2,
//            menus: [] // TODO: 서버에서 메뉴 받아야 함
//        )
//        let viewModel = WriteDetailMenuViewModel(config: config)
//        
//        // TODO: 가게 업데이트 로직이 필요함
//        
//        output.route.send(.pushWriteDetailMenu(viewModel))
    }
    
    private func pushWriteDetailAdditionalInfo() {
        let viewModel = WriteDetailAdditionalInfoViewModel(
            config: WriteDetailAdditionalInfoViewModel.Config(),
            dependency: WriteDetailAdditionalInfoViewModel.Dependency()
        )
        
        // TODO: 가게 업데이트 로직이 필요함
        
        output.route.send(.pushWriteDetailAdditionalInfo(viewModel))
    }
    
    private func handleCompleteTap() {
        output.route.send(.dismiss)
    }
}
