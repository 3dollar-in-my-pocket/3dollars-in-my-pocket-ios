import Foundation

import Model

public protocol CategoryRepository {
    func fetchCategories() async -> Result<[StoreFoodCategoryResponse], Error>
}

public struct CategoryRepositoryImpl: CategoryRepository {
    public init() { }
    
    public func fetchCategories() async -> Result<[StoreFoodCategoryResponse], Error> {
        let request = CategoryApi.fetchCategories
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
