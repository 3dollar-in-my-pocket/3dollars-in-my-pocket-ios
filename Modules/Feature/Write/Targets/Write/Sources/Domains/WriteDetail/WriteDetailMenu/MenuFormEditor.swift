import Combine

import Common
import Model

final class MenuFormEditor {
    let categories: CurrentValueSubject<[StoreFoodCategoryResponse], Never>
    let selectedCategoryIndex = CurrentValueSubject<Int, Never>(0)
    let menus = PassthroughSubject<[MenuInputViewModel], Never>()
    let addedMenu = PassthroughSubject<MenuInputViewModel, Never>()

    private(set) var form: MenuForm

    private var currentCategoryId: String? {
        return form.categories[safe: selectedCategoryIndex.value]?.categoryId
    }

    init(form: MenuForm) {
        self.form = form
        self.categories = CurrentValueSubject(form.categories)
    }

    func reloadMenus() {
        guard let categoryId = currentCategoryId else {
            menus.send([])
            return
        }

        form.seedEmptyMenuIfNeeded(categoryId: categoryId)
        let viewModels = form.menus(categoryId: categoryId).enumerated().map { index, menu in
            makeMenuInputViewModel(index: index, menu: menu, categoryId: categoryId)
        }
        menus.send(viewModels)
    }

    func selectCategory(index: Int) {
        selectedCategoryIndex.send(index)
        reloadMenus()
    }

    func addMenu() {
        guard let categoryId = currentCategoryId else { return }

        form.addMenu(categoryId: categoryId)
        let addedMenus = form.menus(categoryId: categoryId)
        guard let menu = addedMenus.last else { return }
        addedMenu.send(makeMenuInputViewModel(index: addedMenus.count - 1, menu: menu, categoryId: categoryId))
    }

    func deleteMenu(index: Int) {
        guard let categoryId = currentCategoryId else { return }

        form.deleteMenu(categoryId: categoryId, index: index)
        reloadMenus()
    }

    func replaceCategories(_ newCategories: [StoreFoodCategoryResponse]) {
        form.replaceCategories(newCategories)
        categories.send(form.categories)
        selectCategory(index: 0)
    }

    func merge(_ result: MenuExtractionResult) {
        let mergedForm = form.merging(
            categories: result.categories,
            menus: result.menus,
            maximumCategoryCount: WriteDetailCategoryViewModel.Constants.maximumSelectedCategoryCount
        )
        let firstExtractedCategoryId = result.menus.first?.category
        form = mergedForm
        categories.send(form.categories)
        selectCategory(index: form.categories.firstIndex { $0.categoryId == firstExtractedCategoryId } ?? 0)
    }


    private func makeMenuInputViewModel(index: Int, menu: UserStoreMenuRequestV3, categoryId: String) -> MenuInputViewModel {
        let viewModel = MenuInputViewModel(config: .init(index: index, menu: menu))

        viewModel.output.name
            .compactMap { $0 }
            .sink { [weak self] name in
                self?.form.updateName(categoryId: categoryId, index: index, name: name)
            }
            .store(in: &viewModel.cancellables)

        viewModel.output.quantity
            .sink { [weak self] count in
                self?.form.updateCount(categoryId: categoryId, index: index, count: count)
            }
            .store(in: &viewModel.cancellables)

        viewModel.output.price
            .sink { [weak self] price in
                self?.form.updatePrice(categoryId: categoryId, index: index, price: price)
            }
            .store(in: &viewModel.cancellables)

        viewModel.output.didTapDelete
            .sink { [weak self] in
                self?.deleteMenu(index: index)
            }
            .store(in: &viewModel.cancellables)

        return viewModel
    }
}
