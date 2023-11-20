import Foundation

import Model

public protocol ReviewServiceProtocol {
    func fetchStoreReview(storeId: Int, input: FetchStoreReviewRequestInput) async -> Result<ContentsWithCursorResposne<ReviewWithUserApiResponse>, Error>
    
    func reportReview(storeId: Int, reviewId: Int, input: ReportReviewRequestInput) async -> Result<String?, Error>
}

public struct ReviewService: ReviewServiceProtocol {
    public init() { }
    
    public func fetchStoreReview(storeId: Int, input: FetchStoreReviewRequestInput) async -> Result<ContentsWithCursorResposne<ReviewWithUserApiResponse>, Error> {
        let request = FetchStoreReviewRequest(storeId: storeId, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func reportReview(storeId: Int, reviewId: Int, input: ReportReviewRequestInput) async -> Result<String?, Error> {
        let request = ReportReviewRequest(storeId: storeId, reviewId: reviewId, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
