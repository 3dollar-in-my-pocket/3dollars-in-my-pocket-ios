import Foundation
import Combine

import Networking
import Model
import Common
import AppInterface
import DependencyInjection

final class WriteDetailViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let tapFullMap = PassthroughSubject<Void, Never>()
        let tapEditLocation = PassthroughSubject<Void, Never>()
        let storeName = PassthroughSubject<String, Never>()
        let tapSalesType = PassthroughSubject<SalesType, Never>()
        let tapPaymentMethod = PassthroughSubject<PaymentMethod, Never>()
        let tapDay = PassthroughSubject<AppearanceDay, Never>()
        let tapAddCategory = PassthroughSubject<Void, Never>()
        let tapDeleteCategory = PassthroughSubject<Int, Never>()
        let addCategories = PassthroughSubject<[PlatformStoreCategory], Never>()
        let deleteAllCategories = PassthroughSubject<Void, Never>()
        let inputMenuName = PassthroughSubject<(IndexPath, String), Never>()
        let inputMenuPrice = PassthroughSubject<(IndexPath, String), Never>()
        let tapSave = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let isSaveButtonEnable = PassthroughSubject<Bool, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
        let error = PassthroughSubject<Error, Never>()
        let sections = PassthroughSubject<[WriteDetailSection], Never>()
    }
    
    private struct State {
        var storeId: Int?
        var location: Model.Location
        var addess: String
        var name = ""
        var salesType: SalesType?
        var paymentMethods: [PaymentMethod] = []
        var appearanceDays: [AppearanceDay] = []
        var categories: [Model.PlatformStoreCategory] = []
        var menu: [[NewMenu]] = []
        var isEdit: Bool
    }
    
    enum Route {
        case pop
        case presentFullMap
        case presentCategorySelection(CategorySelectionViewModel)
        case dismissWithStoreId(Int)
        case dismissWIthStoreDetailData(StoreDetailData)
    }
    
    struct EditConfig: WriteStoreConfigurable {
        let storeId: Int
        let storeDetailData: StoreDetailData
    }
    
    struct WriteConfig: WriteStoreConfigurable {
        let location: Model.Location
        let address: String
    }
    
    let input = Input()
    let output = Output()
    private var state: State
    private let storeService: StoreServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let analyticsManager: AnalyticsManagerProtocol
    
    init(
        config: WriteStoreConfigurable,
        storeService: StoreServiceProtocol = StoreService(),
        categoryService: CategoryServiceProtocol = CategoryService()
    ) {
        self.storeService = storeService
        self.categoryService = categoryService
        
        guard let appModuleInterface = DIContainer.shared.container.resolve(AppModuleInterface.self) else {
            fatalError("AppModuleInterface가 정의되지 않았습니다.")
        }
        self.analyticsManager = appModuleInterface.analyticsManager
        
        if let writeConfig = config as? WriteConfig {
            self.state = State(
                location: writeConfig.location,
                addess: writeConfig.address,
                isEdit: false
            )
        } else if let editConfig = config as? EditConfig {
            self.state = State(
                storeId: editConfig.storeId,
                location: editConfig.storeDetailData.overview.location,
                addess: editConfig.storeDetailData.overview.address,
                name: editConfig.storeDetailData.overview.storeName,
                salesType: editConfig.storeDetailData.info.salesType,
                paymentMethods: editConfig.storeDetailData.info.paymentMethods,
                appearanceDays: editConfig.storeDetailData.info.appearanceDays,
                categories: editConfig.storeDetailData.overview.categories,
                isEdit: true
            )
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
                owner.sendPageViewLog()
            }
            .store(in: &cancellables)
        
        input.tapFullMap
            .map { .presentFullMap }
            .subscribe(output.route)
            .store(in: &cancellables)
        
        input.tapEditLocation
            .map { .pop }
            .subscribe(output.route)
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
            .handleEvents(receiveOutput: { owner, _ in
                owner.output.showLoading.send(true)
            })
            .map { owner, _ in
                owner.createStoreCreateRequestInput()
            }
            .withUnretained(self)
            .asyncMap { owner, input in
                await owner.storeService.createStore(input: input)
            }
            .withUnretained(self)
            .sink { owner, result in
                owner.output.showLoading.send(false)
                owner.sendSaveClickLog()
                switch result {
                case .success(let response):
                    owner.output.route.send(.dismissWithStoreId(response.storeId))

                case .failure(let error):
                    owner.output.error.send(error)
                }
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
            WriteDetailSection(type: .storeType, items: [.storeType]),
            WriteDetailSection(type: .paymentMethod, items: [.paymentMethod]),
            WriteDetailSection(type: .appearanceDay, items: [.appearanceDay]),
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
        var menuRequestInputs = [Model.StoreMenuRequestInput]()
        for menuGroup in state.menu {
            let emptyMenuCount = menuGroup.filter { !$0.isValid }.count
            var filteredMenuGroup = [NewMenu]()
            if emptyMenuCount == menuGroup.count {
                filteredMenuGroup = [menuGroup[0]]
            } else {
                filteredMenuGroup = menuGroup.filter { $0.isValid }
            }
            
            let requests = filteredMenuGroup.map { menu in
                Model.StoreMenuRequestInput(name: menu.name, price: menu.price, category: menu.category.category)
            }
            
            menuRequestInputs.append(contentsOf: requests)
        }
        
        return StoreCreateRequestInput(
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
    
    private func isAllMenuEntered(section: Int) -> Bool {
        guard let menus = state.menu[safe: section] else { return false }
        
        return !menus.map { $0.isValid }.contains(false)
    }
    
    private func addEmptyMenu(section: Int) {
        guard let category = state.menu[safe: section]?.first?.category else { return }
        
        state.menu[section].append(NewMenu(category: category))
    }
    
    private func sendPageViewLog() {
        analyticsManager.logPageView(screen: .writeAddressDetail, type: WriteDetailViewController.self)
    }
    
    private func sendSaveClickLog() {
        analyticsManager.logEvent(event: .clickSave, screen: .writeAddressDetail)
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
}
