import Foundation

import Networking

final class MetadataManager {
    static let shared = MetadataManager()
    
    private let categoryService: Networking.CategoryServiceProtocol
    
    var categories: [PlatformStoreCategory] = []
    
    init(categoryService: Networking.CategoryServiceProtocol = Networking.CategoryService()) {
        self.categoryService = categoryService
    }
    
    func fetchCategories() {
        Task {
            let result = await categoryService.fetchCategoires()
            
            switch result {
            case .success(let categoryResponse):
                let resultCategories = categoryResponse.map { PlatformStoreCategory(response: $0) }
                categories = resultCategories
                
            case .failure(_):
                break
            }
        }
    }
}
