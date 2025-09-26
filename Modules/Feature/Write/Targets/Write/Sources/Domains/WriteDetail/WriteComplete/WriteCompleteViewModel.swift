import Foundation
import Combine

import Common
import Model
import Networking

extension WriteCompleteViewModel {
    struct Input {
        let didTapAddMenu = PassthroughSubject<Void, Never>()
        let didTapAddAdditionalInfo = PassthroughSubject<Void, Never>()
        let didTapComplete = PassthroughSubject<Void, Never>()
        let updateStore = PassthroughSubject<UserStoreResponse, Never>()
    }
    
    struct Output {
        let isLoading = PassthroughSubject<Bool, Never>()
        let userStoreResponse: CurrentValueSubject<UserStoreResponse, Never>
        let didTapComplete = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pushWriteDetailMenu(WriteDetailMenuViewModel)
        case pushWriteDetailAdditionalInfo(WriteDetailAdditionalInfoViewModel)
        case tosat(String)
        case showErrorAlert(Error)
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        
        init(storeRepository: StoreRepository = StoreRepositoryImpl()) {
            self.storeRepository = storeRepository
        }
    }
    
    struct State {
        var userStoreResponse: UserStoreResponse
        var paymentMethods: [PaymentMethod]
        var appearanceDays: [AppearanceDay]
        var startTime: Date?
        var endTime: Date?
        var menus: [UserStoreMenuRequestV3]
    }
    
    struct Config {
        let userStoreResponse: UserStoreResponse
    }
}

final class WriteCompleteViewModel: BaseViewModel {
    let input = Input()
    let output: Output

    private var state: State
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(userStoreResponse: .init(config.userStoreResponse))
        self.state = State(
            userStoreResponse: config.userStoreResponse,
            paymentMethods: config.userStoreResponse.paymentMethods,
            appearanceDays: config.userStoreResponse.appearanceDays,
            startTime: config.userStoreResponse.openingHours?.startTime?.toDate(),
            endTime: config.userStoreResponse.openingHours?.endTime?.toDate(),
            menus: config.userStoreResponse.menusV3.map { UserStoreMenuRequestV3(response: $0) }
        )
        self.dependency = dependency
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
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                output.didTapComplete.send(String(state.userStoreResponse.storeId))
            })
            .store(in: &cancellables)
        
        input.updateStore
            .sink { [weak self] store in
                self?.state.userStoreResponse = store
                self?.output.userStoreResponse.send(store)
            }
            .store(in: &cancellables)
    }
    
    private func pushWriteDetailMenu() {
        let config = WriteDetailMenuViewModel.Config(
            selectedCategories: state.userStoreResponse.categories,
            menus: [],
            afterCreatedStore: true
        )
        let viewModel = WriteDetailMenuViewModel(config: config)
        viewModel.output.finishInputMenu
            .sink { [weak self] (menus: [UserStoreMenuRequestV3]) in
                self?.state.menus = menus
                self?.patchStore()
            }
            .store(in: &viewModel.cancellables)
        output.route.send(.pushWriteDetailMenu(viewModel))
    }
    
    private func pushWriteDetailAdditionalInfo() {
        let viewModel = WriteDetailAdditionalInfoViewModel(
            config: WriteDetailAdditionalInfoViewModel.Config(afterCreatedStore: true),
            dependency: WriteDetailAdditionalInfoViewModel.Dependency()
        )
        viewModel.output.finishWriteAdditionalInfo
            .sink { [weak self] (paymentMethods: [PaymentMethod], appearanceDays: [AppearanceDay], startTime: Date?, endTime: Date?) in
                self?.state.paymentMethods = paymentMethods
                self?.state.appearanceDays = appearanceDays
                self?.state.startTime = startTime
                self?.state.endTime = endTime
                self?.patchStore()
            }
            .store(in: &viewModel.cancellables)
        output.route.send(.pushWriteDetailAdditionalInfo(viewModel))
    }
    
    private func patchStore() {
        Task { [weak self] in
            guard let self else { return }
            let store = state.userStoreResponse
            do {
                output.isLoading.send(true)
                let input = UserStorePatchRequestV3(
                    latitude: store.location.latitude,
                    longitude: store.location.longitude,
                    storeName: store.name,
                    storeType: store.salesTypeV2?.type,
                    appearanceDays: state.appearanceDays,
                    openingHours: .init(startTime: state.startTime?.toString(format: "HH:mm"), endTime: state.endTime?.toString(format: "HH:mm")),
                    paymentMethods: state.paymentMethods,
                    menus: state.menus
                )

                let response = try await dependency.storeRepository.patchStore(storeId: String(store.storeId), input: input).get()
                
                output.isLoading.send(false)
                self.input.updateStore.send(response)
            } catch {
                output.isLoading.send(false)
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}
