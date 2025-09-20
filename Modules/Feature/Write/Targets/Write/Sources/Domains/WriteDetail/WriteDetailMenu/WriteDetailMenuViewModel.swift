import Combine

import Common
import Model
import Networking

extension WriteDetailMenuViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<Int, Never>()
        let didTapEditCategory = PassthroughSubject<Void, Never>()
        let inputMenuName = PassthroughSubject<(index: Int, name: String), Never>()
        let inputMenuQuantity = PassthroughSubject<(index: Int, quantity: Int?), Never>()
        let inputMenuPrice = PassthroughSubject<(index: Int, price: Int?), Never>()
        let didTapAddMenu = PassthroughSubject<Void, Never>()
        let didTapSkip = PassthroughSubject<Void, Never>()
        let didTapNext = PassthroughSubject<Void, Never>()
        let editCategory = PassthroughSubject<[StoreFoodCategoryResponse], Never>()
    }
    
    struct Output {
        let afterCreatedStore: Bool
        let categories = PassthroughSubject<[StoreFoodCategoryResponse], Never>()
        let selectedCategoryIndex = CurrentValueSubject<Int, Never>(0)
        let menus = PassthroughSubject<[MenuInputViewModel], Never>()
        let addMenus = PassthroughSubject<MenuInputViewModel, Never>()
        let finishInputMenu = PassthroughSubject<[UserStoreMenuRequestV3], Never>()
        let finishInputCategory = PassthroughSubject<[StoreFoodCategoryResponse], Never>()
        let didTapSkip = PassthroughSubject<Void, Never>()
        let toast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case presentCategoryBottomSheet(WriteDetailCategoryBottomSheetViewModel)
        case showErrorAlert(Error)
        case pop
    }
    
    struct Dependency {
        let categoryRepository: CategoryRepository
        
        init(categoryRepository: CategoryRepository = CategoryRepositoryImpl()) {
            self.categoryRepository = categoryRepository
        }
    }
    
    struct State {
        var categories: [StoreFoodCategoryResponse] = []
        var selectedCategories: [StoreFoodCategoryResponse]
        var menus: [String: [UserStoreMenuRequestV3]] = [:]
    }
    
    struct Config {
        let selectedCategories: [StoreFoodCategoryResponse]
        let menus: [UserStoreMenuRequestV3]
        let afterCreatedStore: Bool
    }
}


final class WriteDetailMenuViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    private let dependencies: Dependency

    init(config: Config, dependencies: Dependency = Dependency()) {
        self.output = Output(afterCreatedStore: config.afterCreatedStore)
        self.state = State(
            selectedCategories: config.selectedCategories,
            menus: Dictionary(grouping: config.menus, by: { $0.category })
        )
        self.dependencies = dependencies
        super.init()
    }

    override func bind() {
        input.viewDidLoad
            .sink { [weak self]  in
                guard let self else { return }
                fetchCategories()
                output.categories.send(state.selectedCategories)
                fetchCurrentCategoryMenus()
            }
            .store(in: &cancellables)
        
        input.selectCategory
            .sink { [weak self] index in
                self?.selectCategory(index: index)
            }
            .store(in: &cancellables)
        
        input.didTapEditCategory
            .sink { [weak self] in
                self?.presentWriteDetailCategoryBottomSheet()
            }
            .store(in: &cancellables)
        
        input.inputMenuName
            .sink { [weak self] (index: Int, name: String) in
                self?.inputMenuName(index: index, name: name)
            }
            .store(in: &cancellables)
        
        input.inputMenuQuantity
            .sink { [weak self] (index: Int, quantity: Int?) in
                self?.inputMenuQuantity(index: index, quantity: quantity ?? 0)
            }
            .store(in: &cancellables)
        
        input.inputMenuPrice
            .sink { [weak self] (index: Int, price: Int?) in
                self?.inputMenuPrice(index: index, price: price ?? 0)
            }
            .store(in: &cancellables)
        
        input.didTapAddMenu
            .sink { [weak self] in
                self?.addMenu()
            }
            .store(in: &cancellables)
        
        input.didTapSkip
            .subscribe(output.didTapSkip)
            .store(in: &cancellables)
        
        input.didTapNext
            .sink { [weak self] in
                self?.finishInputMenu()
            }
            .store(in: &cancellables)
        
        input.editCategory
            .sink { [weak self] selectedCategories in
                self?.editCategories(categories: selectedCategories)
            }
            .store(in: &cancellables)
    }
    
    private func fetchCategories() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let categories = try await dependencies.categoryRepository.fetchCategories().get()
                state.categories = categories
            } catch {
                output.route.send(.showErrorAlert(error))
            }
        }
    }
    
    private func fetchCurrentCategoryMenus() {
        guard let currentCategory = state.selectedCategories[safe: output.selectedCategoryIndex.value] else { return }
        
        let currentCategoryMenus: [UserStoreMenuRequestV3]
        if let menus = state.menus[currentCategory.categoryId] {
            currentCategoryMenus = menus
        } else {
            let menus = [UserStoreMenuRequestV3(category: currentCategory.categoryId)]
            state.menus[currentCategory.categoryId] = menus
            currentCategoryMenus = menus
        }
        
        let menuViewModels = currentCategoryMenus.map { MenuInputViewModel(config: .init(menu: $0)) }
        for (index, viewModel) in menuViewModels.enumerated() {
            bindMenuViewModel(index: index, viewModel: viewModel)
        }
        
        output.menus.send(menuViewModels)
    }
    
    private func selectCategory(index: Int) {
        output.selectedCategoryIndex.send(index)
        fetchCurrentCategoryMenus()
    }
    
    private func inputMenuName(index: Int, name: String) {
        guard let currentCategory = state.selectedCategories[safe: output.selectedCategoryIndex.value] else { return }
        
        state.menus[currentCategory.categoryId]?[index].name = name
    }
    
    private func inputMenuQuantity(index: Int, quantity: Int) {
        guard let currentCategory = state.selectedCategories[safe: output.selectedCategoryIndex.value] else { return }
        
        state.menus[currentCategory.categoryId]?[index].count = quantity
    }
    
    private func inputMenuPrice(index: Int, price: Int) {
        guard let currentCategory = state.selectedCategories[safe: output.selectedCategoryIndex.value] else { return }
        
        state.menus[currentCategory.categoryId]?[index].price = price
    }
    
    private func presentWriteDetailCategoryBottomSheet() {
        let config = WriteDetailCategoryBottomSheetViewModel.Config(
            categories: state.categories,
            selectedCategories: state.selectedCategories
        )
        let viewModel = WriteDetailCategoryBottomSheetViewModel(config: config)
        
        viewModel.output.finishEditCategory
            .subscribe(input.editCategory)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentCategoryBottomSheet(viewModel))
    }
    
    private func addMenu() {
        guard let currentCategory = state.selectedCategories[safe: output.selectedCategoryIndex.value] else { return }
        
        let newMenu = UserStoreMenuRequestV3(category: currentCategory.categoryId)
        let index = state.menus[currentCategory.categoryId]?.count ?? 0
        
        state.menus[currentCategory.categoryId]?.append(newMenu)
        
        let newMenuViewModel = MenuInputViewModel(config: .init(menu: newMenu))
        bindMenuViewModel(index: index, viewModel: newMenuViewModel)
        
        output.addMenus.send(newMenuViewModel)
    }
    
    private func bindMenuViewModel(index: Int, viewModel: MenuInputViewModel) {
        viewModel.output.name
            .compactMap { $0 }
            .map { (index, $0) }
            .subscribe(input.inputMenuName)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.quantity
            .compactMap { $0 }
            .map { (index, $0) }
            .subscribe(input.inputMenuQuantity)
            .store(in: &viewModel.cancellables)
        
        viewModel.output.price
            .compactMap { $0 }
            .map { (index, $0) }
            .subscribe(input.inputMenuPrice)
            .store(in: &viewModel.cancellables)
    }
    
    private func finishInputMenu() {
        let menus = state.menus.flatMap { $0.value }
        
        guard validateCount(menus: menus) else {
            output.toast.send(Strings.WriteDetailMenu.Toast.validateMenu)
            return
        }
        
        guard validatePrice(menus: menus) else {
            output.toast.send(Strings.WriteDetailMenu.Toast.validatePrice)
            return
        }
        output.finishInputMenu.send(menus)
        output.finishInputCategory.send(state.selectedCategories)
        
        if output.afterCreatedStore {
            output.route.send(.pop)
        }
    }
    
    private func editCategories(categories: [StoreFoodCategoryResponse]) {
        for oldCategory in state.selectedCategories {
            if categories.contains(where: { $0.categoryId == oldCategory.categoryId }).isNot {
                state.menus[oldCategory.categoryId] = nil
            }
        }
        
        state.selectedCategories = categories
        
        let menus = categories.map { UserStoreMenuRequestV3(name: "", category: $0.categoryId) }
        state.menus = Dictionary(grouping: menus, by: { $0.category} )
        
        output.categories.send(categories)
        output.selectedCategoryIndex.send(0)
        fetchCurrentCategoryMenus()
    }
    
    private func validateCount(menus: [UserStoreMenuRequestV3]) -> Bool {
        for menu in menus {
            if let count = menu.count, count <= 0 {
                return false
            }
        }
        return true
    }
    
    private func validatePrice(menus: [UserStoreMenuRequestV3]) -> Bool {
        for menu in menus {
            if let price = menu.price, price <= 0 {
                return false
            }
        }
        return true
    }
}
