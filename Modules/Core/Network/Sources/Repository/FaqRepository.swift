import Foundation

import Model

public protocol FaqRepository {
    func fetchFaq(category: String?) async -> Result<[FaqResponse], Error>
    
    func fetchFaqCategory() async -> Result<[FaqCategoryResponse], Error>
}

public struct FaqRepositoryImpl: FaqRepository {
    public init() { }
    
    public func fetchFaq(category: String?) async -> Result<[FaqResponse], Error> {
        let request = FaqApi.fetchFaq(category: category)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchFaqCategory() async -> Result<[FaqCategoryResponse], Error> {
        let request = FaqApi.fetchFaqCategory
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
