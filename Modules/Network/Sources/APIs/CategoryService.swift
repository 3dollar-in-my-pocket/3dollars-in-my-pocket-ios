import Foundation

import Model

public protocol CategoryServiceProtocol {
    func fetchCategoires() async -> Result<[PlatformStoreCategoryResponse], Error>
}

public struct CategoryService: CategoryServiceProtocol {
    public init() { }
    
    public func fetchCategoires() async -> Result<[PlatformStoreCategoryResponse], Error> {
        let request = FetchCategoryRequest()
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
