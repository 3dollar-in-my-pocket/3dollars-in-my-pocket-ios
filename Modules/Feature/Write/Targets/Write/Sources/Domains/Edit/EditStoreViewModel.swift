import Foundation
import Combine
import CoreLocation

import Common
import Model
import Networking
import WriteInterface

extension EditStoreViewModel {
    struct Input {
        let didTapAddress = PassthroughSubject<Void, Never>()
        let didTapStoreInfo = PassthroughSubject<Void, Never>()
        let didTapMenu = PassthroughSubject<Void, Never>()
        let didTapEdit = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let store: CurrentValueSubject<UserStoreResponse, Never>
        let menuCount: CurrentValueSubject<Int, Never>
        let changedCount = CurrentValueSubject<Int?, Never>(nil)
        let route = PassthroughSubject<Route, Never>()
        let isLoading = PassthroughSubject<Bool, Never>()
        let onEdit = PassthroughSubject<UserStoreResponse, Never>()
    }
    
    enum Route {
        case dismiss
        case pushEditAddress(WriteAddressViewModel)
        case editStoreInfo(EditStoreInfoViewModel)
        case editMenu(WriteDetailMenuViewModel)
        case pop
        case toast(String)
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        
        init(storeRepository: StoreRepository = StoreRepositoryImpl()) {
            self.storeRepository = storeRepository
        }
    }
    
    private struct State {
        var originalStore: UserStoreResponse
        var currentStore: UserStoreResponse
        var editedMenus: [UserStoreMenuRequestV3]?
    }
}

final class EditStoreViewModel: BaseViewModel, EditStoreViewModelInterface  {
    let input = Input()
    let output: Output
    private var state: State
    private let dependency: Dependency
    
    var onEdit: PassthroughSubject<UserStoreResponse, Never> {
        output.onEdit
    }
    
    convenience init(config: EditStoreViewModelConfig) {
        self.init(config: config, dependency: Dependency())
    }
    
    init(config: EditStoreViewModelConfig, dependency: Dependency = Dependency()) {
        self.dependency = dependency
        self.state = State(
            originalStore: config.store,
            currentStore: config.store
        )
        self.output = Output(
            store: .init(config.store),
            menuCount: .init(config.store.menusV3.count)
        )
        
        super.init()
    }
    
    override func bind() {
        input.didTapAddress
            .sink { [weak self] in
                self?.pushEditAddress()
            }
            .store(in: &cancellables)
        
        input.didTapStoreInfo
            .sink { [weak self] in
                self?.pushEditStoreInfo()
            }
            .store(in: &cancellables)
        
        input.didTapMenu
            .sink { [weak self] in
                self?.pushEditMenu()
            }
            .store(in: &cancellables)
        
        input.didTapEdit
            .sink { [weak self] in
                self?.editStore()
            }
            .store(in: &cancellables)
    }
    
    private func pushEditAddress() {
        guard let address = state.currentStore.address.fullAddress else { return }
        let config = WriteAddressViewModelConfig(
            address: address,
            location: state.currentStore.location.toCLLocation
        )
        let viewModel = WriteAddressViewModel(config: config)
        
        viewModel.output.finishWriteAddress
            .sink { [weak self] (address: String, location: CLLocation) in
                self?.didUpdatedAddress(address: address, location: location)
                self?.updateEditedCount()
                self?.output.route.send(.pop)
            }
            .store(in: &viewModel.cancellables)
        output.route.send(.pushEditAddress(viewModel))
    }
    
    private func pushEditStoreInfo() {
        let config = EditStoreInfoViewModel.Config(store: state.currentStore)
        let viewModel = EditStoreInfoViewModel(config: config)
        
        viewModel.output.editedStoreInfo
            .sink { [weak self] store in
                self?.state.currentStore = store
                self?.updateEditedCount()
                self?.output.store.send(store)
            }
            .store(in: &viewModel.cancellables)
        output.route.send(.editStoreInfo(viewModel))
    }
    
    private func pushEditMenu() {
        let menus: [UserStoreMenuRequestV3]
        if let editedMenus = state.editedMenus {
            menus = editedMenus
        } else {
            menus = state.currentStore.menusV3.map { UserStoreMenuRequestV3(response: $0) }
        }
        
        let config = WriteDetailMenuViewModel.Config(
            selectedCategories: state.currentStore.categories,
            menus: menus,
            afterCreatedStore: true
        )
        let viewModel = WriteDetailMenuViewModel(config: config)
        
        viewModel.output.finishInputMenu
            .sink { [weak self] menus in
                self?.state.editedMenus = menus
                self?.updateEditedCount()
                self?.output.menuCount.send(menus.count)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.output.finishInputCategory
            .sink { [weak self] categories in
                self?.state.currentStore.categories = categories
            }
            .store(in: &viewModel.cancellables)
        output.route.send(.editMenu(viewModel))
    }
    
    private func editStore() {
        output.isLoading.send(true)
        
        Task {
            let storeId = state.originalStore.storeId
            var input = UserStorePatchRequestV3(response: state.currentStore)
            
            if let editedMenu = state.editedMenus {
                input.menus = editedMenu
            }
            
            do {
                let response = try await dependency.storeRepository.patchStore(
                    storeId: String(storeId),
                    input: input
                ).get()
                
                output.onEdit.send(response)
                output.isLoading.send(false)
                output.route.send(.toast("가게 정보가 수정되었습니다"))
                output.route.send(.dismiss)
            } catch {
                output.isLoading.send(false)
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func didUpdatedAddress(address: String, location: CLLocation) {
        state.currentStore.address.fullAddress = address
        state.currentStore.location = LocationResponse(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        output.store.send(state.currentStore)
    }
    
    private func updateEditedCount() {
        var editedCount = 0
        
        if state.currentStore.address.fullAddress != state.originalStore.address.fullAddress {
            editedCount += 1
        }
        
        if state.currentStore.name != state.originalStore.name {
            editedCount += 1
        }
        
        if state.currentStore.salesTypeV2?.type != state.originalStore.salesTypeV2?.type {
            editedCount += 1
        }
        
        if state.currentStore.paymentMethods != state.originalStore.paymentMethods {
            editedCount += 1
        }
        
        if state.currentStore.appearanceDays != state.originalStore.appearanceDays {
            editedCount += 1
        }
        
        if state.currentStore.openingHours != state.originalStore.openingHours {
            editedCount += 1
        }
        
        if let editedMenus = state.editedMenus,
           editedMenus.count != state.originalStore.menusV3.count {
            editedCount += 1
        }

        output.changedCount.send(editedCount)
    }
}


private extension UserStorePatchRequestV3 {
    init(response: UserStoreResponse) {
        self = .init(
            latitude: response.location.latitude,
            longitude: response.location.longitude,
            storeName: response.name,
            salesType: response.salesTypeV2?.type,
            appearanceDays: response.appearanceDays,
            openingHours: response.openingHours,
            paymentMethods: response.paymentMethods,
            menus: response.menusV3.map { .init(response: $0) }
        )
    }
}
