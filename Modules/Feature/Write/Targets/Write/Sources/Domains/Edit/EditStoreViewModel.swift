import Foundation
import Combine

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
        let didUpdateStore = PassthroughSubject<UserStoreResponse, Never>()
    }
    
    struct Output {
        let store: CurrentValueSubject<UserStoreResponse, Never>
        let changedCount = CurrentValueSubject<Int?, Never>(nil)
        let route = PassthroughSubject<Route, Never>()
        let isLoading = PassthroughSubject<Bool, Never>()
        let onEdit = PassthroughSubject<UserStoreResponse, Never>()
    }
    
    enum Route {
        case dismiss
        case editAddress
        case editStoreInfo
        case editMenu
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
        self.output = Output(store: .init(config.store))
        
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
        
        input.didUpdateStore
            .sink { [weak self] store in
                self?.state.currentStore = store
                self?.output.store.send(store)
            }
            .store(in: &cancellables)
    }
    
    private func pushEditAddress() {
        
    }
    
    private func pushEditStoreInfo() {
        
    }
    
    private func pushEditMenu() {
        
    }
    
    private func editStore() {
        output.isLoading.send(true)
        
        Task {
            let storeId = state.originalStore.storeId
            
            do {
                let response = try await dependency.storeRepository.patchStore(
                    storeId: String(storeId),
                    input: .init(response: state.currentStore)
                ).get()
                
                output.onEdit.send(response)
                output.route.send(.toast("가게 정보가 수정되었습니다"))
                output.route.send(.dismiss)
            } catch {
                output.isLoading.send(false)
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}


private extension UserStorePatchRequestV3 {
    init(response: UserStoreResponse) {
        self = .init(
            latitude: response.location.latitude,
            longitude: response.location.longitude,
            storeName: response.name,
            storeType: response.salesTypeV2?.type,
            appearanceDays: response.appearanceDays,
            openingHours: response.openingHours,
            paymentMethods: response.paymentMethods,
            menus: response.menusV3.map { .init(response: $0) }
        )
    }
}
