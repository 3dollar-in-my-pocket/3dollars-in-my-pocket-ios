import Foundation
import CoreLocation

import Model

public protocol StoreServiceProtocol {
    func isStoresExistedAround(distance: Double, mapLocation: CLLocation) async -> Result<IsStoresExistedAroundResponse, Error>
    
    func createStore(input: StoreCreateRequestInput) async -> Result<StoreCategoryResponse, Error>
    
    func fetchAroundStores(input: FetchAroundStoreInput, latitude: Double, longitude: Double) async -> Result<ContentsWithCursorResposne<PlatformStoreWithDetailResponse>, Error>
    
    func fetchStoreDetail(input: FetchStoreDetailInput) async -> Result<StoreWithDetailApiResponse, Error>
    
    func saveStore(storeType: StoreType, storeId: String, isDelete: Bool) async -> Result<String, Error>
    
    func reportStore(storeId: Int, reportReason: String) async -> Result<StoreDeleteResponse, Error>
    
    func fetchReportReasons(group: ReportGroup) async -> Result<ReportReasonApiResponse, Error>
    
    func writeReview(input: WriteReviewRequestInput) async -> Result<ReviewWithUserApiResponse, Error>
}

public struct StoreService: StoreServiceProtocol {
    public init() { }
    
    public func isStoresExistedAround(distance: Double, mapLocation: CLLocation) async -> Result<IsStoresExistedAroundResponse, Error> {
        let request = IsStoreExistNearbyRequest(distance: distance, mapLocation: mapLocation)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func createStore(input: StoreCreateRequestInput) async -> Result<StoreCategoryResponse, Error> {
        let request = StoreCreateRequest(requestInput: input)
        
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
    
    public func fetchReportReasons(group: ReportGroup) async -> Result<ReportReasonApiResponse, Error> {
        let request = FetchReportReasonListRequest(group: group)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func writeReview(input: WriteReviewRequestInput) async -> Result<ReviewWithUserApiResponse, Error> {
        let request = WriteReviewRequest(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
