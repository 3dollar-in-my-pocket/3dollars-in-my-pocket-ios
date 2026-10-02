import Foundation

import Common
import Model

struct MenuForm {
    enum ValidationError {
        case invalidCount
        case invalidPrice
    }

    private(set) var categories: [StoreFoodCategoryResponse]
    private var menusByCategoryId: [String: [UserStoreMenuRequestV3]]

    init(categories: [StoreFoodCategoryResponse], menus: [UserStoreMenuRequestV3]) {
        self.categories = categories
        self.menusByCategoryId = Dictionary(grouping: menus, by: { $0.category })
    }

    var allMenus: [UserStoreMenuRequestV3] {
        let categoryIds = categories.map(\.categoryId)
        let ordered = categoryIds.flatMap { menusByCategoryId[$0] ?? [] }
        let others = menusByCategoryId
            .filter { categoryIds.contains($0.key).isNot }
            .flatMap(\.value)
        return ordered + others
    }

    func menus(categoryId: String) -> [UserStoreMenuRequestV3] {
        return menusByCategoryId[categoryId] ?? []
    }

    mutating func seedEmptyMenuIfNeeded(categoryId: String) {
        guard menusByCategoryId[categoryId]?.isEmpty ?? true else { return }
        menusByCategoryId[categoryId] = [UserStoreMenuRequestV3(category: categoryId)]
    }

    mutating func addMenu(categoryId: String) {
        menusByCategoryId[categoryId, default: []].append(UserStoreMenuRequestV3(category: categoryId))
    }

    mutating func deleteMenu(categoryId: String, index: Int) {
        guard menusByCategoryId[categoryId]?.indices.contains(index) == true else { return }
        menusByCategoryId[categoryId]?.remove(at: index)
    }

    mutating func updateName(categoryId: String, index: Int, name: String) {
        guard menusByCategoryId[categoryId]?.indices.contains(index) == true else { return }
        menusByCategoryId[categoryId]?[index].name = name
    }

    mutating func updateCount(categoryId: String, index: Int, count: Int?) {
        guard menusByCategoryId[categoryId]?.indices.contains(index) == true else { return }
        menusByCategoryId[categoryId]?[index].count = count
    }

    mutating func updatePrice(categoryId: String, index: Int, price: Int?) {
        guard menusByCategoryId[categoryId]?.indices.contains(index) == true else { return }
        menusByCategoryId[categoryId]?[index].price = price
    }

    mutating func replaceCategories(_ newCategories: [StoreFoodCategoryResponse]) {
        let newCategoryIds = newCategories.map(\.categoryId)
        for category in categories where newCategoryIds.contains(category.categoryId).isNot {
            menusByCategoryId[category.categoryId] = nil
        }
        for categoryId in newCategoryIds where menusByCategoryId[categoryId] == nil {
            menusByCategoryId[categoryId] = [UserStoreMenuRequestV3(category: categoryId)]
        }
        categories = newCategories
    }

    func validate() -> ValidationError? {
        let menus = allMenus
        if menus.contains(where: { ($0.count ?? 1) <= 0 }) {
            return .invalidCount
        }
        if menus.contains(where: { ($0.price ?? 1) <= 0 }) {
            return .invalidPrice
        }
        return nil
    }
}
