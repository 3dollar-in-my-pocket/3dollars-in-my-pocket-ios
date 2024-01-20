import Foundation

import Model

public protocol FaqServiceProtocol {
    func fetchFaq(category: String?) async -> Result<[FaqResponse], Error>
    
    func fetchFaqCategory() async -> Result<[FaqCategoryResponse], Error>
}

public struct FaqService: FaqServiceProtocol {
    public init() { }
    
    public func fetchFaq(category: String?) async -> Result<[FaqResponse], Error> {
        let request = FetchFaqRequest(category: category)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchFaqCategory() async -> Result<[FaqCategoryResponse], Error> {
        let request = FetchFaqCategoryRequest()
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
