import Foundation

import Model

struct MenuExtractionResult {
    static let maximumCategoryCount = 10

    let categories: [StoreFoodCategoryResponse]
    let menus: [UserStoreMenuRequestV3]
    let recognizedMenuCount: Int

    init(categories: [StoreFoodCategoryResponse], menus: [UserStoreMenuRequestV3], recognizedMenuCount: Int) {
        self.categories = categories
        self.menus = menus
        self.recognizedMenuCount = recognizedMenuCount
    }

    init(response: StoreMenuExtractionListResponse) {
        var categories: [StoreFoodCategoryResponse] = []
        for menu in response.menus where categories.contains(where: { $0.categoryId == menu.category.categoryId }) == false {
            categories.append(menu.category)
        }
        let limitedCategories = Array(categories.prefix(Self.maximumCategoryCount))
        let categoryIds = Set(limitedCategories.map(\.categoryId))

        self.categories = limitedCategories
        self.menus = response.menus
            .filter { categoryIds.contains($0.category.categoryId) }
            .map {
                UserStoreMenuRequestV3(
                    name: $0.name,
                    count: $0.count,
                    price: $0.price,
                    category: $0.category.categoryId
                )
            }
        self.recognizedMenuCount = response.menus.count
    }
}
