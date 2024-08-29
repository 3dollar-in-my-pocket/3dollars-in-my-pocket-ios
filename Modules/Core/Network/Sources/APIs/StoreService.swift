import Foundation
import CoreLocation

import Model

public protocol StoreServiceProtocol {
    func isStoresExistedAround(distance: Double, mapLocation: CLLocation) async -> Result<IsStoresExistedAroundResponse, Error>
    
    func createStore(input: StoreCreateRequestInput) async -> Result<StoreCreateResponse, Error>
    
    func editStore(storeId: Int, input: EditStoreRequestInput) async -> Result<StoreCreateResponse, Error>
    
    func fetchAroundStores(input: FetchAroundStoreInput, latitude: Double, longitude: Double) async -> Result<ContentsWithCursorResposne<PlatformStoreWithDetailResponse>, Error>
    
    func fetchStoreDetail(input: FetchStoreDetailInput) async -> Result<StoreWithDetailApiResponse, Error>
    
    func saveStore(storeType: StoreType, storeId: String, isDelete: Bool) async -> Result<String, Error>
    
    func reportStore(storeId: Int, reportReason: String) async -> Result<StoreDeleteResponse, Error>
    
    func writeReview(input: WriteReviewRequestInput) async -> Result<ReviewWithUserApiResponse, Error>
    
    func uploadPhotos(storeId: Int, photos: [Data]) async -> Result<[StoreImageApiResponse], Error>
    
    func fetchStorePhotos(storeId: Int, cursor: String?) async -> Result<ContentsWithCursorResposne<StoreImageWithApiResponse>, Error>
    
    func editReview(reviewId: Int, input: EditReviewRequestInput) async -> Result<StoreReviewResponse, Error>
    
    func deletePhoto(photoId: Int) async -> Result<String?, Error>

    func fetchBossStoreDetail(input: FetchBossStoreDetailInput) async -> Result<BossStoreDetailResponse, Error>
    
    func fetchNewPosts(storeId: String, cursor: CursorRequestInput) async -> Result<ContentsWithCursorResposne<PostWithStoreResponse>, Error>
}

public struct StoreService: StoreServiceProtocol {
    public init() { }
    
    public func isStoresExistedAround(distance: Double, mapLocation: CLLocation) async -> Result<IsStoresExistedAroundResponse, Error> {
        let request = IsStoreExistNearbyRequest(distance: distance, mapLocation: mapLocation)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func createStore(input: StoreCreateRequestInput) async -> Result<StoreCreateResponse, Error> {
        let request = StoreCreateRequest(requestInput: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func editStore(storeId: Int, input: EditStoreRequestInput) async -> Result<StoreCreateResponse, Error> {
        let request = EditStoreRequest(storeId: storeId, requestInput: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchAroundStores(input: FetchAroundStoreInput, latitude: Double, longitude: Double) async -> Result<ContentsWithCursorResposne<PlatformStoreWithDetailResponse>, Error> {
        let request = FetchAroundStoreRequest(requestInput: input, latitude: latitude, longitude: longitude)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchStoreDetail(input: FetchStoreDetailInput) async -> Result<StoreWithDetailApiResponse, Error> {
        let request = FetchStoreDetailRequest(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func saveStore(storeType: StoreType, storeId: String, isDelete: Bool) async -> Result<String, Error> {
        let request = SaveStoreRequest(storeType: storeType, storeId: storeId, isDelete: isDelete)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func reportStore(storeId: Int, reportReason: String) async -> Result<StoreDeleteResponse, Error> {
        let request = ReportStoreRequest(storeId: storeId, reportReason: reportReason)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func writeReview(input: WriteReviewRequestInput) async -> Result<ReviewWithUserApiResponse, Error> {
        let request = WriteReviewRequest(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func uploadPhotos(storeId: Int, photos: [Data]) async -> Result<[StoreImageApiResponse], Error> {
        let request = UploadPhotoRequest(storeId: storeId, photos: photos)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchStorePhotos(storeId: Int, cursor: String?) async -> Result<ContentsWithCursorResposne<StoreImageWithApiResponse>, Error> {
        let request = FetchStorePhotoRequest(storeId: storeId, size: 20, cursor: cursor)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func editReview(reviewId: Int, input: EditReviewRequestInput) async -> Result<StoreReviewResponse, Error> {
        let request = EditReviewRequest(reviewId: reviewId, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func deletePhoto(photoId: Int) async -> Result<String?, Error> {
        let request = DeletePhotoRequest(photoId: photoId)

        return await NetworkManager.shared.request(requestType: request)
    }

    public func fetchBossStoreDetail(input: FetchBossStoreDetailInput) async -> Result<BossStoreDetailResponse, Error> {
        let request = StoreApi.fetchBossStoreDetail(input)

        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchNewPosts(storeId: String, cursor: CursorRequestInput) async -> Result<ContentsWithCursorResposne<PostWithStoreResponse>, Error> {
        let request = FetchStoreNewPostsRequest(storeId: storeId, input: cursor)

        return await NetworkManager.shared.request(requestType: request)
    }
}
