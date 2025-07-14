import Foundation
import CoreLocation

import Model

public protocol StoreRepository {
    func createStore(input: StoreCreateRequestInput) async -> Result<UserStoreCreateResponse, Error>
    
    func editStore(storeId: Int, input: EditStoreRequestInput) async -> Result<UserStoreCreateResponse, Error>
    
    func fetchAroundStores(input: FetchAroundStoreInput) async -> Result<ContentsWithCursorResponse<StoreWithExtraResponse>, Error>
    
    func fetchStoreDetail(input: FetchStoreDetailInput) async -> Result<UserStoreDetailResponse, Error>
    
    func saveStore(storeId: String, isDelete: Bool) async -> Result<String, Error>
    
    func reportStore(storeId: Int, reportReason: String) async -> Result<StoreDeleteResponse, Error>
    
    func writeReview(input: WriteReviewRequestInput) async -> Result<StoreReviewWithWriterResponse, Error>
    
    func uploadPhotos(storeId: Int, photos: [Data]) async -> Result<[StoreImageResponse], Error>
    
    func fetchStorePhotos(storeId: Int, cursor: String?) async -> Result<ContentsWithCursorResponse<StoreImageWithApiResponse>, Error>
    
    func editReview(reviewId: Int, input: EditReviewRequestInput) async -> Result<StoreReviewResponse, Error>
    
    func deletePhoto(photoId: Int) async -> Result<String?, Error>

    func fetchBossStoreDetail(input: FetchBossStoreDetailInput) async -> Result<BossStoreDetailResponse, Error>
    
    func fetchNewPosts(storeId: String, cursor: CursorRequestInput) async -> Result<ContentsWithCursorResponse<PostWithStoreResponse>, Error>
    
    func togglePostSticker(storeId: String, postId: String, input: StoreNewsPostStickersReplaceRequest) async -> Result<String, Error>
    
    func existsFeedbackOnDateByAccount(storeId: Int) async -> Result<FeedbackExistsResponse, Error>
    
    func fetchStore(input: FetchStoreInput) async -> Result<StoreDetailResponse, Error>
}

public struct StoreRepositoryImpl: StoreRepository {
    public init() { }
    
    public func createStore(input: StoreCreateRequestInput) async -> Result<UserStoreCreateResponse, Error> {
        let request = StoreApi.createStore(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func editStore(storeId: Int, input: EditStoreRequestInput) async -> Result<UserStoreCreateResponse, Error> {
        let request = StoreApi.editStore(storeId: storeId, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchAroundStores(input: FetchAroundStoreInput) async -> Result<ContentsWithCursorResponse<StoreWithExtraResponse>, Error> {
        let request = StoreApi.fetchAroundStores(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchStoreDetail(input: FetchStoreDetailInput) async -> Result<UserStoreDetailResponse, Error> {
        let request = StoreApi.fetchStoreDetail(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func saveStore(storeId: String, isDelete: Bool) async -> Result<String, Error> {
        let request = StoreApi.saveStore(storeId: storeId, isDelete: isDelete)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func reportStore(storeId: Int, reportReason: String) async -> Result<StoreDeleteResponse, Error> {
        let request = StoreApi.reportStore(storeId: storeId, reportReason: reportReason)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func writeReview(input: WriteReviewRequestInput) async -> Result<StoreReviewWithWriterResponse, Error> {
        let request = StoreApi.writeReview(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func uploadPhotos(storeId: Int, photos: [Data]) async -> Result<[StoreImageResponse], Error> {
        let request = UploadPhotoRequest(storeId: storeId, photos: photos)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchStorePhotos(storeId: Int, cursor: String?) async -> Result<ContentsWithCursorResponse<StoreImageWithApiResponse>, Error> {
        let request = StoreApi.fetchStorePhotos(storeId: storeId, cursor: cursor)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func editReview(reviewId: Int, input: EditReviewRequestInput) async -> Result<StoreReviewResponse, Error> {
        let request = StoreApi.editReview(reviewId: reviewId, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func deletePhoto(photoId: Int) async -> Result<String?, Error> {
        let request = StoreApi.deletePhoto(photoId: photoId)

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchBossStoreDetail(input: FetchBossStoreDetailInput) async -> Result<BossStoreDetailResponse, Error> {
        let request = StoreApi.fetchBossStoreDetail(input)

        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchNewPosts(storeId: String, cursor: CursorRequestInput) async -> Result<ContentsWithCursorResponse<PostWithStoreResponse>, Error> {
        let request = StoreApi.fetchStoreNewPosts(storeId: storeId, cursorInput: cursor)

        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func togglePostSticker(storeId: String, postId: String, input: StoreNewsPostStickersReplaceRequest) async -> Result<String, Error> {
        let request = StoreApi.togglePostSticker(storeId: storeId, postId: postId, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func existsFeedbackOnDateByAccount(storeId: Int) async -> Result<FeedbackExistsResponse, Error> {
        let request = StoreApi.existsFeedbackOnDateByAccount(storeId: storeId)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchStore(input: FetchStoreInput) async -> Result<StoreDetailResponse, Error> {
        let request = StoreApi.fetchStore(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
