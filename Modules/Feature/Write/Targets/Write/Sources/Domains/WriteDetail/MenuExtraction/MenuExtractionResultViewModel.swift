import Combine
import Foundation

import Common
import Model

extension MenuExtractionResultViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<Int, Never>()
        let didTapAddMenu = PassthroughSubject<Void, Never>()
        let didTapRegister = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let afterCreatedStore: Bool
        let recognizedMenuCount: Int
        let categories: CurrentValueSubject<[StoreFoodCategoryResponse], Never>
        let selectedCategoryIndex: CurrentValueSubject<Int, Never>
        let menus: PassthroughSubject<[MenuInputViewModel], Never>
        let addMenus: PassthroughSubject<MenuInputViewModel, Never>
        let toast = PassthroughSubject<String, Never>()
        let finishRegister = PassthroughSubject<MenuExtractionResult, Never>()
    }

    struct Config {
        let result: MenuExtractionResult
        let afterCreatedStore: Bool
    }
}

final class MenuExtractionResultViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private let editor: MenuFormEditor

    init(config: Config) {
        let editor = MenuFormEditor(form: MenuForm(categories: config.result.categories, menus: config.result.menus))
        self.editor = editor
        self.output = Output(
            afterCreatedStore: config.afterCreatedStore,
            recognizedMenuCount: config.result.recognizedMenuCount,
            categories: editor.categories,
            selectedCategoryIndex: editor.selectedCategoryIndex,
            menus: editor.menus,
            addMenus: editor.addedMenu
        )
        super.init()
    }

    override func bind() {
        input.viewDidLoad
            .sink { [weak self] in
                self?.editor.reloadMenus()
            }
            .store(in: &cancellables)

        input.selectCategory
            .sink { [weak self] index in
                self?.editor.selectCategory(index: index)
            }
            .store(in: &cancellables)

        input.didTapAddMenu
            .sink { [weak self] in
                self?.editor.addMenu()
            }
            .store(in: &cancellables)

        input.didTapRegister
            .sink { [weak self] in
                self?.register()
            }
            .store(in: &cancellables)
    }

    private func register() {
        switch editor.form.validate() {
        case .invalidCount:
            output.toast.send(Strings.WriteDetailMenu.Toast.validateMenu)
        case .invalidPrice:
            output.toast.send(Strings.WriteDetailMenu.Toast.validatePrice)
        case .none:
            output.finishRegister.send(MenuExtractionResult(
                categories: editor.form.categories,
                menus: editor.form.allMenus,
                recognizedMenuCount: output.recognizedMenuCount
            ))
        }
    }
}
