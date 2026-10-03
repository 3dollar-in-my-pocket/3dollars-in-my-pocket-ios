import Combine
import Foundation

import Common
import Model
import Networking
import Log

extension WriteDetailMenuViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<Int, Never>()
        let didTapEditCategory = PassthroughSubject<Void, Never>()
        let didTapAddMenu = PassthroughSubject<Void, Never>()
        let didTapSkip = PassthroughSubject<Void, Never>()
        let didTapNext = PassthroughSubject<Void, Never>()
        let editCategory = PassthroughSubject<[StoreFoodCategoryResponse], Never>()
        let didSelectMenuImage = PassthroughSubject<Data, Never>()
        let finishMenuExtraction = PassthroughSubject<MenuExtractionResult, Never>()
    }

    struct Output {
        let screenName: ScreenName = .writeDetailMenu
        let afterCreatedStore: Bool
        let isMenuExtractionAvailable: CurrentValueSubject<Bool, Never>
        let categories: CurrentValueSubject<[StoreFoodCategoryResponse], Never>
        let selectedCategoryIndex: CurrentValueSubject<Int, Never>
        let menus: PassthroughSubject<[MenuInputViewModel], Never>
        let addMenus: PassthroughSubject<MenuInputViewModel, Never>
        let finishInputMenu = PassthroughSubject<[UserStoreMenuRequestV3], Never>()
        let finishInputCategory = PassthroughSubject<[StoreFoodCategoryResponse], Never>()
        let didTapSkip = PassthroughSubject<Void, Never>()
        let toast = PassthroughSubject<String, Never>()
        let route = PassthroughSubject<Route, Never>()
    }

    enum Route {
        case presentCategoryBottomSheet(WriteDetailCategoryBottomSheetViewModel)
        case pushMenuExtractionLoading(MenuExtractionLoadingViewModel)
        case popToSelf
        case showErrorAlert(Error)
        case pop
    }

    struct Dependency {
        let categoryRepository: CategoryRepository
        let logManager: LogManagerProtocol

        init(
            categoryRepository: CategoryRepository = CategoryRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.categoryRepository = categoryRepository
            self.logManager = logManager
        }
    }

    struct State {
        var categories: [StoreFoodCategoryResponse] = []
    }

    struct Config {
        let selectedCategories: [StoreFoodCategoryResponse]
        let menus: [UserStoreMenuRequestV3]
        let afterCreatedStore: Bool
        let menuExtractionUsage: MenuExtractionUsage
    }
}


final class WriteDetailMenuViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state = State()
    private let config: Config
    private let editor: MenuFormEditor
    private let dependencies: Dependency

    init(config: Config, dependencies: Dependency = Dependency()) {
        let editor = MenuFormEditor(form: MenuForm(categories: config.selectedCategories, menus: config.menus))
        self.config = config
        self.editor = editor
        self.output = Output(
            afterCreatedStore: config.afterCreatedStore,
            isMenuExtractionAvailable: config.menuExtractionUsage.isAvailable,
            categories: editor.categories,
            selectedCategoryIndex: editor.selectedCategoryIndex,
            menus: editor.menus,
            addMenus: editor.addedMenu
        )
        self.dependencies = dependencies
        super.init()
    }

    override func bind() {
        input.viewDidLoad
            .sink { [weak self] in
                self?.fetchCategories()
                self?.editor.reloadMenus()
            }
            .store(in: &cancellables)

        input.selectCategory
            .sink { [weak self] index in
                self?.editor.selectCategory(index: index)
            }
            .store(in: &cancellables)

        input.didTapEditCategory
            .sink { [weak self] in
                self?.presentWriteDetailCategoryBottomSheet()
            }
            .store(in: &cancellables)

        input.didTapAddMenu
            .sink { [weak self] in
                self?.editor.addMenu()
            }
            .store(in: &cancellables)

        input.didTapSkip
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.sendClickSkipLog()
            })
            .subscribe(output.didTapSkip)
            .store(in: &cancellables)

        input.didTapNext
            .sink { [weak self] in
                self?.finishInputMenu()
            }
            .store(in: &cancellables)

        input.editCategory
            .sink { [weak self] selectedCategories in
                self?.editor.replaceCategories(selectedCategories)
            }
            .store(in: &cancellables)

        input.didSelectMenuImage
            .sink { [weak self] image in
                self?.pushMenuExtractionLoading(image: image)
            }
            .store(in: &cancellables)

        input.finishMenuExtraction
            .sink { [weak self] result in
                self?.applyMenuExtraction(result)
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

    private func presentWriteDetailCategoryBottomSheet() {
        let config = WriteDetailCategoryBottomSheetViewModel.Config(
            categories: state.categories,
            selectedCategories: editor.form.categories
        )
        let viewModel = WriteDetailCategoryBottomSheetViewModel(config: config)

        viewModel.output.finishEditCategory
            .subscribe(input.editCategory)
            .store(in: &viewModel.cancellables)

        output.route.send(.presentCategoryBottomSheet(viewModel))
    }

    private func pushMenuExtractionLoading(image: Data) {
        let config = MenuExtractionLoadingViewModel.Config(
            image: image,
            afterCreatedStore: output.afterCreatedStore,
            menuExtractionUsage: self.config.menuExtractionUsage
        )
        let viewModel = MenuExtractionLoadingViewModel(config: config)

        viewModel.output.finishExtraction
            .subscribe(input.finishMenuExtraction)
            .store(in: &cancellables)

        output.route.send(.pushMenuExtractionLoading(viewModel))
    }

    private func applyMenuExtraction(_ result: MenuExtractionResult) {
        editor.merge(result)
        output.route.send(.popToSelf)
    }

    private func finishInputMenu() {
        switch editor.form.validate() {
        case .invalidCount:
            output.toast.send(Strings.WriteDetailMenu.Toast.validateMenu)
            return
        case .invalidPrice:
            output.toast.send(Strings.WriteDetailMenu.Toast.validatePrice)
            return
        case .none:
            break
        }

        sendClickNextLog()
        output.finishInputMenu.send(editor.form.allMenus)
        output.finishInputCategory.send(editor.form.categories)

        if output.afterCreatedStore {
            output.route.send(.pop)
        }
    }

    private func sendClickSkipLog() {
        dependencies.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .skip
        ))
    }

    private func sendClickNextLog() {
        dependencies.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .next
        ))
    }
}
