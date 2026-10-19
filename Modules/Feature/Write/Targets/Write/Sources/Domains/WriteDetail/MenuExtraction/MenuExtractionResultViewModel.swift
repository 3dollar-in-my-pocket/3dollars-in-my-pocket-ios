import Combine
import Foundation

import Common
import Model
import Log

extension MenuExtractionResultViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let selectCategory = PassthroughSubject<Int, Never>()
        let didTapAddMenu = PassthroughSubject<Void, Never>()
        let didTapRegister = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let screenName: ScreenName = .writeDetailMenuExtractionResult
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
        let flow: MenuExtractionFlow
    }

    struct Dependency {
        let logManager: LogManagerProtocol

        init(logManager: LogManagerProtocol = LogManager.shared) {
            self.logManager = logManager
        }
    }
}

final class MenuExtractionResultViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private let editor: MenuFormEditor
    private let config: Config
    private let dependency: Dependency

    init(config: Config, dependency: Dependency = Dependency()) {
        let editor = MenuFormEditor(form: MenuForm(categories: config.result.categories, menus: config.result.menus))
        self.editor = editor
        self.config = config
        self.dependency = dependency
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
            let menus = editor.form.allMenus
            sendClickRegisterLog(finalMenuCount: menus.count)
            output.finishRegister.send(MenuExtractionResult(
                categories: editor.form.categories,
                menus: menus,
                recognizedMenuCount: output.recognizedMenuCount
            ))
        }
    }

    private func sendClickRegisterLog(finalMenuCount: Int) {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .register,
            extraParameters: [
                .recognizedMenuCount: output.recognizedMenuCount,
                .finalMenuCount: finalMenuCount,
                .flow: config.flow.rawValue
            ]
        ))
    }
}
