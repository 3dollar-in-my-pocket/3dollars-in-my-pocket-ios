import Combine
import CoreLocation

import Common
import Model
import Networking

extension WriteNavigationViewModel {
    struct Input {
        let fetchedCategories = PassthroughSubject<[StoreFoodCategoryResponse], Never>()
        let finishWriteAddress = PassthroughSubject<(address: String, location: CLLocation), Never>()
        let finishWriteDetailInfo = PassthroughSubject<(storeName: String, storeType: UserStoreCreateRequestV3.StoreType), Never>()
        let finishSelectCategory = PassthroughSubject<[StoreFoodCategoryResponse], Never>()
        let finishWriteMenus = PassthroughSubject<[UserStoreMenuRequestV3], Never>()
        let finishWriteAdditionalInfo = PassthroughSubject<(
            paymentMethods: [PaymentMethod],
            appearanceDays: [AppearanceDay],
            startTime: Date?,
            endTime: Date?
        ), Never>()
        let didTapSkip = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let isLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        let commonRepository: CommonRepository
        
        init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            commonRepository: CommonRepository = CommonRepositoryImpl()
        ) {
            self.storeRepository = storeRepository
            self.commonRepository = commonRepository
        }
    }
    
    enum Route {
        case pushWriteDetailInfo(WriteDetailInfoViewModel)
        case pushWriteDetailCategory(WriteDetailCategoryViewModel)
        case pushWriteDetailMenu(WriteDetailMenuViewModel)
        case pushWriteDetailAdditionalInfo(WriteDetailAdditionalInfoViewModel)
        case pushWriteComplete(WriteCompleteViewModel)
        case toast(String)
        case showErrorAlert(Error)
    }
    
    private struct State {
        var location: CLLocation?
        var address: String?
        var storeName: String?
        var storeType: UserStoreCreateRequestV3.StoreType?
        var categories: [StoreFoodCategoryResponse] = []
        var selectedCategories: [StoreFoodCategoryResponse] = []
        var menus: [UserStoreMenuRequestV3] = []
        var paymentMethods: [PaymentMethod] = []
        var appearanceDays: [AppearanceDay] = []
        var startTime: Date?
        var endTime: Date?
    }
}

final class WriteNavigationViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private var state = State()
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        super.init()
    }
    
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
            .sink { [weak self] (storeName: String, storeType: UserStoreCreateRequestV3.StoreType) in
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
            .sink { [weak self] (menus: [UserStoreMenuRequestV3]) in
                self?.state.menus = menus
                self?.pushWriteDetailAdditionalInfo()
            }
            .store(in: &cancellables)
        
        input.finishWriteAdditionalInfo
            .sink { [weak self] (paymentMethods: [PaymentMethod], appearanceDays: [AppearanceDay], startTime: Date?, endTime: Date?) in
                self?.state.paymentMethods = paymentMethods
                self?.state.appearanceDays = appearanceDays
                self?.state.startTime = startTime
                self?.state.endTime = endTime
                
                self?.createStore()
            }
            .store(in: &cancellables)
        
        input.didTapSkip
            .sink { [weak self] in
                self?.createStore()
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
        viewModel.output.didTapSkip
            .subscribe(input.didTapSkip)
            .store(in: &viewModel.cancellables)
        output.route.send(.pushWriteDetailMenu(viewModel))
    }
    
    private func pushWriteDetailAdditionalInfo() {
        let config = WriteDetailAdditionalInfoViewModel.Config()
        let viewModel = WriteDetailAdditionalInfoViewModel(config: config)
        
        viewModel.output.finishWriteAdditionalInfo
            .subscribe(input.finishWriteAdditionalInfo)
            .store(in: &viewModel.cancellables)
        viewModel.output.didTapSkip
            .subscribe(input.didTapSkip)
            .store(in: &viewModel.cancellables)
        output.route.send(.pushWriteDetailAdditionalInfo(viewModel))
    }
    
    private func pushWriteComplete(userStoreResponse: UserStoreResponse) {
        let config = WriteCompleteViewModel.Config(userStoreResponse: userStoreResponse)
        let viewModel = WriteCompleteViewModel(config: config)
        output.route.send(.pushWriteComplete(viewModel))
    }
    
    private func createStore() {
        guard let location = state.location,
              let storeName = state.storeName else {
            output.route.send(.toast("필수 데이터가 입력되지 않았어요. 다시 시도해주세요."))
            return
        }
        
        Task { [weak self] in
            guard let self else { return }
            do {
                output.isLoading.send(true)
                let nonceToken = try await dependency.commonRepository.createNonceToken().get().nonce
                let input = UserStoreCreateRequestV3(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    storeName: storeName,
                    storeType: state.storeType,
                    appearanceDays: state.appearanceDays,
                    openingHours: StoreOpeningHours(
                        startTime: state.startTime?.toString(format: "HH:mm"),
                        endTime: state.endTime?.toString(format: "HH:mm")
                    ),
                    paymentMethods: state.paymentMethods,
                    menus: state.menus,
                    nonceToken: nonceToken
                )
                let response = try await dependency.storeRepository.createStore(input: input, nonceToken: nonceToken).get()
                
                output.isLoading.send(false)
                pushWriteComplete(userStoreResponse: response)
            } catch {
                output.isLoading.send(false)
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}
