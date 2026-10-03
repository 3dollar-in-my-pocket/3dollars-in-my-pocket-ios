import Foundation

import Model
import Networking

final class MockCategoryRepository: CategoryRepository {
    var fetchCategoriesResult: Result<[StoreFoodCategoryResponse], Error> = .success([])

    func fetchCategories() async -> Result<[StoreFoodCategoryResponse], Error> {
        fetchCategoriesResult
    }
}
