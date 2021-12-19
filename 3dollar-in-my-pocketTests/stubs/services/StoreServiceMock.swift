//
//  StoreServiceMock.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/09/25.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation
import CoreLocation

import RxSwift

@testable import dollar_in_my_pocket

struct StoreServiceMock: StoreServiceProtocol {
    var searchNearStoresObservable: Observable<[StoreWithVisitsAndDistanceResponse]>?
    var saveStoreObservable: Observable<Store>?
    
    func searchNearStores(
        currentLocation: CLLocation,
        mapLocation: CLLocation,
        distance: Double,
        category: StoreCategory?,
        orderType: StoreOrder?
    ) -> Observable<[StoreWithVisitsAndDistanceResponse]> {
        return self.searchNearStoresObservable ??
            .error(CommonError(desc: "searchNearStoresObservable가 정의되지 않았습니다."))
    }
    
    func saveStore(store: Store) -> Observable<Store> {
        return self.saveStoreObservable ??
            .error(CommonError(desc: "saveStoreObservable가 정의되지 않았습니다."))
    }
    
    func savePhoto(storeId: Int, photos: [UIImage]) -> Observable<[StoreImageResponse]> {
        return .empty()
    }
    
    func getPhotos(storeId: Int) -> Observable<[StoreImageResponse]> {
        return .empty()
    }
    
    func deletePhoto(photoId: Int) -> Observable<String> {
        return .empty()
    }
    
    func updateStore(
        storeId: Int,
        updateStoreRequest: AddStoreRequest
    ) -> Observable<StoreInfoResponse> {
        return .empty()
    }
    
    func getStoreDetail(
        storeId: Int,
        latitude: Double,
        longitude: Double,
        startDate: Date,
        endDate: Date
    ) -> Observable<StoreDetailResponse> {
        return .empty()
    }
    
    func fetchRegisteredStores(
        cursor: Int?,
        size: Int
    ) -> Observable<Pagination<StoreWithVisitsResponse>> {
        return .empty()
    }
    
    func deleteStore(
        storeId: Int,
        deleteReasonType: DeleteReason
    ) -> Observable<StoreDeleteResponse> {
        return .empty()
    }
}
