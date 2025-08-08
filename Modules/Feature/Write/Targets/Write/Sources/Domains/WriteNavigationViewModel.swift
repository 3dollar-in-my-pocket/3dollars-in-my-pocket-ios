import Combine
import CoreLocation

import Common
import Model

extension WriteNavigationViewModel {
    struct Input {
        let fetchedCategories = PassthroughSubject<[StoreFoodCategoryResponse], Never>()
        let finishWriteAddress = PassthroughSubject<(address: String, location: CLLocation), Never>()
        let finishWriteDetailInfo = PassthroughSubject<(storeName: String, storeType: UserStoreCreateRequest.StoreType), Never>()
        let finishSelectCategory = PassthroughSubject<[StoreFoodCategoryResponse], Never>()
        let finishWriteMenus = PassthroughSubject<[UserStoreMenuV2Request], Never>()
    }
    
    struct Output {
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pushWriteDetailInfo(WriteDetailInfoViewModel)
        case pushWriteDetailCategory(WriteDetailCategoryViewModel)
        case pushWriteDetailMenu(WriteDetailMenuViewModel)
    }
    
    private struct State {
        var location: CLLocation?
        var address: String?
        var storeName: String?
        var storeType: UserStoreCreateRequest.StoreType?
        var categories: [StoreFoodCategoryResponse] = []
        var selectedCategories: [StoreFoodCategoryResponse] = []
        var menus: [UserStoreMenuV2Request] = []
    }
}

final class WriteNavigationViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    
    override func bind() {
        input.fetchedCategories
            .sink { [weak self] (categories: [StoreFoodCategoryResponse]) in
                self?.state.categories = categories
            }
            .store(in: &cancellables)
        
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
        
        input.finishSelectCategory
            .sink { [weak self] (category: [StoreFoodCategoryResponse]) in
                self?.state.selectedCategories = category
                self?.pushWriteDetailMenu()
            }
            .store(in: &cancellables)
        
        input.finishWriteMenus
            .sink { [weak self] (menus: [UserStoreMenuV2Request]) in
                self?.state.menus = menus
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
        let viewModel = WriteDetailCategoryViewModel()
        
        viewModel.output.finishSelectCategory
            .subscribe(input.finishSelectCategory)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.fetchedCategories
            .subscribe(input.fetchedCategories)
            .store(in: &viewModel.cancellables)
        output.route.send(.pushWriteDetailCategory(viewModel))
    }
    
    private func pushWriteDetailMenu() {
        let config = WriteDetailMenuViewModel.Config(
            categories: state.categories,
            selectedCategories: state.selectedCategories,
            menus: []
        )
        let viewModel = WriteDetailMenuViewModel(config: config)
        
        viewModel.output.finishInputMenu
            .subscribe(input.finishWriteMenus)
            .store(in: &viewModel.cancellables)
        output.route.send(.pushWriteDetailMenu(viewModel))
    }
}
