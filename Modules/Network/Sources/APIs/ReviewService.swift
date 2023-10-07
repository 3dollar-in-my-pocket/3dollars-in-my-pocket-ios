import Foundation

import Model

public protocol ReviewServiceProtocol {
    func fetchStoreReview(storeId: Int, input: FetchStoreReviewRequestInput) async -> Result<ContentsWithCursorResposne<ReviewWithUserApiResponse>, Error>
}

public struct ReviewService: ReviewServiceProtocol {
    public init() { }
    
    public func fetchStoreReview(storeId: Int, input: FetchStoreReviewRequestInput) async -> Result<ContentsWithCursorResposne<ReviewWithUserApiResponse>, Error> {
        let request = FetchStoreReviewRequest(storeId: storeId, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
