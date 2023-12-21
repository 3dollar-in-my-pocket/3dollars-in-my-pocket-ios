import Foundation
import Combine

import Networking
import Model
import Common
import Log

final class WriteDetailViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let tapFullMap = PassthroughSubject<Void, Never>()
        let tapEditLocation = PassthroughSubject<Void, Never>()
        let storeName = PassthroughSubject<String, Never>()
        let tapSalesType = PassthroughSubject<SalesType, Never>()
        let tapPaymentMethod = PassthroughSubject<PaymentMethod, Never>()
        let tapDay = PassthroughSubject<AppearanceDay, Never>()
        let inputStartDate = PassthroughSubject<String?, Never>()
        let inputEndDate = PassthroughSubject<String?, Never>()
        let tapAddCategory = PassthroughSubject<Void, Never>()
        let tapDeleteCategory = PassthroughSubject<Int, Never>()
        let addCategories = PassthroughSubject<[PlatformStoreCategory], Never>()
        let deleteAllCategories = PassthroughSubject<Void, Never>()
        let inputMenuName = PassthroughSubject<(IndexPath, String), Never>()
        let inputMenuPrice = PassthroughSubject<(IndexPath, String), Never>()
        let tapSave = PassthroughSubject<Void, Never>()
        
        // From WriteDetail
        let onEditLocation = PassthroughSubject<(address: String, location: Location), Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .writeAddressDetail
        let isCloseButtonHidden: CurrentValueSubject<Bool, Never>
        let isSaveButtonEnable = PassthroughSubject<Bool, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
        let error = PassthroughSubject<Error, Never>()
        let sections = PassthroughSubject<[WriteDetailSection], Never>()
    }
    
    private struct State {
        var storeId: Int?
        var location: Location
        var addess: String?
        var name = ""
        var salesType: SalesType?
        var paymentMethods: [PaymentMethod] = []
        var appearanceDays: [AppearanceDay] = []
        var startDate: String?
        var endDate: String?
        var categories: [PlatformStoreCategory] = []
        var menu: [[NewMenu]] = []
        var isEdit: Bool
    }
    
    enum Route {
        case pop
        case presentWriteAddress(WriteAddressViewModel)
        case presentMapDetail(Location, String)
        case presentCategorySelection(CategorySelectionViewModel)
        case dismissWithStoreId(Int)
        case dismissWithUpdatedStore(StoreCreateResponse)
    }
    
    struct EditConfig: WriteStoreConfigurable {
        let storeId: Int
        let storeDetailData: StoreDetailData
    }
    
    struct WriteConfig: WriteStoreConfigurable {
        let location: Location
        let address: String
    }
    
    let input = Input()
    let output: Output
    private var state: State
    private let storeService: StoreServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let logManager: LogManagerProtocol
    
    init(
        config: WriteStoreConfigurable,
        storeService: StoreServiceProtocol = StoreService(),
        categoryService: CategoryServiceProtocol = CategoryService(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.storeService = storeService
        self.categoryService = categoryService
        self.logManager = logManager
        
        if let writeConfig = config as? WriteConfig {
            self.state = State(
                location: writeConfig.location,
                addess: writeConfig.address,
                isEdit: false
            )
            self.output = Output(isCloseButtonHidden: .init(false))
        } else if let editConfig = config as? EditConfig {
            var menus: [[NewMenu]] = []
            
            for category in editConfig.storeDetailData.overview.categories {
                var categoryMenus: [NewMenu] = []
                
                for menu in editConfig.storeDetailData.menus {
                    if menu.category == category {
                        categoryMenus.append(NewMenu(category: menu.category, name: menu.name ?? "", price: menu.price ?? ""))
                    }
                }
                menus.append(categoryMenus)
            }
            
            self.state = State(
                storeId: editConfig.storeId,
                location: editConfig.storeDetailData.overview.location,
                addess: editConfig.storeDetailData.overview.address,
                name: editConfig.storeDetailData.overview.storeName,
                salesType: editConfig.storeDetailData.info.salesType,
                paymentMethods: editConfig.storeDetailData.info.paymentMethods,
                appearanceDays: editConfig.storeDetailData.info.appearanceDays,
                categories: editConfig.storeDetailData.overview.categories,
                menu: menus,
                isEdit: true
            )
            self.output = Output(isCloseButtonHidden: .init(true))
        } else {
            fatalError("올바른 접근이 아닙니다.")
        }
        
        super.init()
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { owner, _ in
                owner.updateSections()
                owner.updateSaveButtonEnable()
            }
            .store(in: &cancellables)
        
        input.tapFullMap
            .withUnretained(self)
            .map { (owner: WriteDetailViewModel, _) in
                Route.presentMapDetail(owner.state.location, owner.state.name)
            }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.tapEditLocation
            .withUnretained(self)
            .sink(receiveValue: { (owner: WriteDetailViewModel, _) in
                owner.pushWriteAddress()
            })
            .store(in: &cancellables)
        
        input.storeName
            .withUnretained(self)
            .sink { owner, name in
                owner.state.name = name
                owner.updateSaveButtonEnable()
            }
            .store(in: &cancellables)
        
        input.tapSalesType
            .withUnretained(self)
            .sink { owner, salesType in
                owner.state.salesType = salesType
            }
            .store(in: &cancellables)
        
        input.tapPaymentMethod
            .withUnretained(self)
            .sink { owner, paymentMethod in
                if let targetIndex = owner.state.paymentMethods.firstIndex(of: paymentMethod) {
                    owner.state.paymentMethods.remove(at: targetIndex)
                } else {
                    owner.state.paymentMethods.append(paymentMethod)
                }
            }
            .store(in: &cancellables)
        
        input.tapDay
            .withUnretained(self)
            .sink { owner, dayOfTheWeek in
                if let targetIndex = owner.state.appearanceDays.firstIndex(of: dayOfTheWeek) {
                    owner.state.appearanceDays.remove(at: targetIndex)
                } else {
                    owner.state.appearanceDays.append(dayOfTheWeek)
                }
            }
            .store(in: &cancellables)
        
        input.inputStartDate
            .withUnretained(self)
            .sink { (owner: WriteDetailViewModel, startDate: String?) in
                owner.state.startDate = startDate
            }
            .store(in: &cancellables)
        
        input.inputEndDate
            .withUnretained(self)
            .sink { (owner: WriteDetailViewModel, endDate: String?) in
                owner.state.endDate = endDate
            }
            .store(in: &cancellables)
        
        input.tapAddCategory
            .withUnretained(self)
            .sink(receiveValue: { (owner: WriteDetailViewModel, _) in
                owner.presentCategorySelection()
            })
            .store(in: &cancellables)
        
        input.tapDeleteCategory
            .withUnretained(self)
            .sink { owner, index in
                owner.state.categories.remove(at: index)
                owner.state.menu.remove(at: index)
                owner.updateSaveButtonEnable()
                owner.updateSections()
            }
            .store(in: &cancellables)
        
        input.addCategories
            .withUnretained(self)
            .sink { owner, categories in
                var updatedMenus = [[NewMenu]]()
                for category in categories {
                    if let index = owner.state.categories.firstIndex(of: category) {
                        updatedMenus.append(owner.state.menu[index])
                    } else {
                        updatedMenus.append([NewMenu(category: category), NewMenu(category: category)])
                    }
                }
                
                owner.state.categories = categories
                owner.state.menu = updatedMenus
                owner.updateSaveButtonEnable()
                owner.updateSections()
            }
            .store(in: &cancellables)
        
        input.deleteAllCategories
            .withUnretained(self)
            .sink { owner, _ in
                owner.state.categories.removeAll()
                owner.state.menu.removeAll()
                owner.updateSaveButtonEnable()
                owner.updateSections()
            }
            .store(in: &cancellables)
        
        input.inputMenuName
            .withUnretained(self)
            .sink { owner, nameWithIndex in
                let (indexPath, name) = nameWithIndex
                guard owner.isExistMenu(indexPath: indexPath) else { return }
                
                owner.state.menu[indexPath.section][indexPath.row].name = name
                
                if owner.isAllMenuEntered(section: indexPath.section) {
                    owner.addEmptyMenu(section: indexPath.section)
                    owner.updateSections()
                }
            }
            .store(in: &cancellables)
        
        input.inputMenuPrice
            .withUnretained(self)
            .sink { owner, priceWithIndex in
                let (indexPath, price) = priceWithIndex
                guard owner.isExistMenu(indexPath: indexPath) else { return }
                
                owner.state.menu[indexPath.section][indexPath.row].price = price
                
                if owner.isAllMenuEntered(section: indexPath.section) {
                    owner.addEmptyMenu(section: indexPath.section)
                    owner.updateSections()
                }
            }
            .store(in: &cancellables)
        
        input.tapSave
            .withUnretained(self)
            .sink(receiveValue: { (owner: WriteDetailViewModel, _) in
                if owner.state.isEdit {
                    owner.editStore()
                } else {
                    owner.createStore()
                }
            })
            .store(in: &cancellables)
        
        input.onEditLocation
            .withUnretained(self)
            .sink { (owner: WriteDetailViewModel, data: (String, Location)) in
                let (address, location) = data
                
                owner.state.addess = address
                owner.state.location = location
                owner.updateSections()
            }
            .store(in: &cancellables)
    }
    
    private func updateSaveButtonEnable() {
        let isEnable = state.name.isNotEmpty && state.categories.isNotEmpty
        output.isSaveButtonEnable.send(isEnable)
    }
    
    private func updateSections() {
        var menuGroupViewModels: [WriteDetailMenuGroupViewModel] = []
        
        for (index, category) in state.categories.enumerated() {
            let menus = state.menu[safe: index] ?? []
            let state = WriteDetailMenuGroupViewModel.State(menuIndex: index, category: category, menu: menus)
            let viewModel = WriteDetailMenuGroupViewModel(state: state)
            
            bindCellViewModel(viewModel)
            menuGroupViewModels.append(viewModel)
        }
        let menuGroups = menuGroupViewModels.map { WriteDetailSectionItem.menuGroup($0) }
        
        let sections: [WriteDetailSection] = [
            WriteDetailSection(type: .map, items: [.map(state.location)]),
            WriteDetailSection(type: .address, items: [.address(state.addess)]),
            WriteDetailSection(type: .name, items: [.name(state.name)]),
            WriteDetailSection(type: .storeType, items: [.storeType(state.salesType)]),
            WriteDetailSection(type: .paymentMethod, items: [.paymentMethod(state.paymentMethods)]),
            WriteDetailSection(type: .appearanceDay, items: [.appearanceDay(state.appearanceDays)]),
            WriteDetailSection(type: .time, items: [.time(createTimeCellViewModel())]),
            WriteDetailSection(type: .category, items: [ .categoryCollection([nil] + state.categories)] + menuGroups)
        ]
        output.sections.send(sections)
    }
    
    private func isExistMenu(indexPath: IndexPath) -> Bool {
        guard let categoryMenus = state.menu[safe: indexPath.section],
              let _ = categoryMenus[safe: indexPath.row] else { return false }
        
        return true
    }
    
    private func createStoreCreateRequestInput() -> StoreCreateRequestInput {
        var menuRequestInputs = [StoreMenuRequestInput]()
        for menuGroup in state.menu {
            let emptyMenuCount = menuGroup.filter { !$0.isValid }.count
            var filteredMenuGroup = [NewMenu]()
            if emptyMenuCount == menuGroup.count {
                filteredMenuGroup = [menuGroup[0]]
            } else {
                filteredMenuGroup = menuGroup.filter { $0.isValid }
            }
            
            let requests = filteredMenuGroup.map { menu in
                StoreMenuRequestInput(name: menu.name, price: menu.price, category: menu.category.categoryId)
            }
            
            menuRequestInputs.append(contentsOf: requests)
        }
        
        return StoreCreateRequestInput(
            latitude: state.location.latitude,
            longitude: state.location.longitude,
            storeName: state.name,
            storeType: state.salesType?.rawValue,
            appearanceDaysV2: [],
            paymentMethods: state.paymentMethods.map { $0.rawValue },
            menus: menuRequestInputs
        )
    }
    
    private func createEditStoreRequestInput() -> EditStoreRequestInput {
        var menuRequestInputs = [StoreMenuRequestInput]()
        for menuGroup in state.menu {
            let emptyMenuCount = menuGroup.filter { !$0.isValid }.count
            var filteredMenuGroup = [NewMenu]()
            if emptyMenuCount == menuGroup.count {
                filteredMenuGroup = [menuGroup[0]]
            } else {
                filteredMenuGroup = menuGroup.filter { $0.isValid }
            }
            
            let requests = filteredMenuGroup.map { menu in
                StoreMenuRequestInput(name: menu.name, price: menu.price, category: menu.category.categoryId)
            }
            
            menuRequestInputs.append(contentsOf: requests)
        }
        
        return EditStoreRequestInput(
            latitude: state.location.latitude,
            longitude: state.location.longitude,
            storeName: state.name,
            storeType: state.salesType?.rawValue,
            appearanceDays: state.appearanceDays.map { $0.rawValue },
            paymentMethods: state.paymentMethods.map { $0.rawValue },
            menus: menuRequestInputs
        )
    }
    
    private func bindCellViewModel(_ viewModel: WriteDetailMenuGroupViewModel) {
        viewModel.output.inputMenuName
            .subscribe(input.inputMenuName)
            .store(in: &cancellables)
        
        viewModel.output.inputMenuPrice
            .subscribe(input.inputMenuPrice)
            .store(in: &cancellables)
    }
    
    private func createTimeCellViewModel() -> WriteDetailTimeCellViewModel {
        let config = WriteDetailTimeCellViewModel.Config(
            startDate: state.startDate,
            endDate: state.endDate
        )
        let viewModel = WriteDetailTimeCellViewModel(config: config)
        
        viewModel.output.inputStartDate
            .subscribe(input.inputStartDate)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.inputEndDate
            .subscribe(input.inputEndDate)
            .store(in: &viewModel.cancellables)
        
        return viewModel
    }
    
    private func isAllMenuEntered(section: Int) -> Bool {
        guard let menus = state.menu[safe: section] else { return false }
        
        return !menus.map { $0.isValid }.contains(false)
    }
    
    private func addEmptyMenu(section: Int) {
        guard let category = state.menu[safe: section]?.first?.category else { return }
        
        state.menu[section].append(NewMenu(category: category))
    }
    
    private func sendSaveClickLog() {
        logManager.sendEvent(LogEvent(
            screen: output.screenName,
            eventName: .clickWriteStore
        ))
    }
    
    private func presentCategorySelection() {
        Task {
            let result = await categoryService.fetchCategoires()
            
            switch result {
            case .success(let response):
                let categories = response.map { PlatformStoreCategory(response: $0) }
                let config = CategorySelectionViewModel.Config(
                    categories: categories,
                    selectedCategories: state.categories
                )
                let viewModel = CategorySelectionViewModel(config: config)
                
                viewModel.output.onSelectCategories
                    .subscribe(input.addCategories)
                    .store(in: &viewModel.cancellables)
                
                output.route.send(.presentCategorySelection(viewModel))
                
            case .failure(let error):
                output.error.send(error)
            }
        }
    }
    
    private func pushWriteAddress() {
        let config = WriteAddressViewModel.Config(
            type: .edit,
            address: state.addess ?? "",
            cameraPosition: state.location
        )
        let viewModel = WriteAddressViewModel(config: config)
        
        viewModel.output.editLocation
            .subscribe(input.onEditLocation)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentWriteAddress(viewModel))
    }
    
    private func createStore() {
        Task {
            sendSaveClickLog()
            output.showLoading.send(true)
            let input = createStoreCreateRequestInput()
            
            let result = await storeService.createStore(input: input)
            
            output.showLoading.send(false)
            switch result {
            case .success(let response):
                output.route.send(.dismissWithStoreId(response.storeId))
                
            case .failure(let error):
                output.error.send(error)
            }
        }
    }
    
    private func editStore() {
        guard let storeId = state.storeId else { return }
        let input = createEditStoreRequestInput()
        output.showLoading.send(true)
        
        Task {
            let result = await storeService.editStore(storeId: storeId, input: input)
            
            output.showLoading.send(false)
            switch result {
            case .success(let response):
                output.route.send(.dismissWithUpdatedStore(response))
                
            case .failure(let error):
                output.error.send(error)
            }
        }
    }
}
