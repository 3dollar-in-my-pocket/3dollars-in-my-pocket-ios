import Foundation

import Model

public protocol ReviewRepository {
    func fetchStoreReview(storeId: Int, input: FetchStoreReviewRequestInput) async -> Result<ContentsWithCursorResponse<StoreReviewWithWriterResponse>, Error>
    
    func reportReview(storeId: Int, reviewId: Int, input: ReportReviewRequestInput) async -> Result<String?, Error>
    
    func fetchMyStoreReview(input: CursorRequestInput) async -> Result<ContentsWithCursorResponse<StoreReviewWithDetailApiResponse>, Error>
    
    func toggleReviewSticker(storeId: Int, reviewId: Int, input: StoreReviewStickerListReplaceInput) async -> Result<String?, Error>
    
    func deleteReview(reviewId: Int) async -> Result<String?, Error>
}

public struct ReviewRepositoryImpl: ReviewRepository {
    public init() { }
    
    public func fetchStoreReview(storeId: Int, input: FetchStoreReviewRequestInput) async -> Result<ContentsWithCursorResponse<StoreReviewWithWriterResponse>, Error> {
        let request = ReviewApi.fetchStoreReview(storeId: storeId, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func reportReview(storeId: Int, reviewId: Int, input: ReportReviewRequestInput) async -> Result<String?, Error> {
        let request = ReviewApi.reportReview(storeId: storeId, reviewId: reviewId, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchMyStoreReview(input: CursorRequestInput) async -> Result<ContentsWithCursorResponse<StoreReviewWithDetailApiResponse>, Error> {
        let request = ReviewApi.fetchMyStoreReview(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func toggleReviewSticker(storeId: Int, reviewId: Int, input: StoreReviewStickerListReplaceInput) async -> Result<String?, Error> {
        let request = ReviewApi.toggleReviewSticker(storeId: storeId, reviewId: reviewId, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func deleteReview(reviewId: Int) async -> Result<String?, Error> {
        let request = ReviewApi.deleteReview(reviewId: reviewId)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
