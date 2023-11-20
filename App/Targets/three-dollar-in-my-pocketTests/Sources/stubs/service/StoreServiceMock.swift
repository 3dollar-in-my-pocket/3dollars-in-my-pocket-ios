//
//  StoreServiceMock.swift
//  3dollar-in-my-pocketTests
//
//  Created by Hyun Sik Yoo on 2021/09/25.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import UIKit
import CoreLocation

import RxSwift

@testable import dollar_in_my_pocket

struct StoreServiceMock: StoreServiceProtocol {
    func searchNearStores(currentLocation: CLLocation?, mapLocation: CLLocation, distance: Double, category: StreetFoodStoreCategory?, orderType: StoreOrder?) -> Observable<[StoreWithVisitsAndDistanceResponse]> {
        return .empty()
    }
    
    func searchNearStores(categoryId: String?, distance: Double?, currentLocation: CLLocation, mapLocation: CLLocation, orderType: dollar_in_my_pocket.StoreOrder?) -> RxSwift.Observable<[dollar_in_my_pocket.StoreProtocol]> {
        return .empty()
    }
    
    func searchNearBossStores(categoryId: String?, distance: Double?, currentLocation: CLLocation, mapLocation: CLLocation, orderType: dollar_in_my_pocket.BossStoreOrderType?) -> RxSwift.Observable<[dollar_in_my_pocket.StoreProtocol]> {
        return .empty()
    }
    
    func isStoresExistedAround(distance: Double, mapLocation: CLLocation) -> RxSwift.Observable<dollar_in_my_pocket.CheckExistStoresNearbyResponse> {
        return .empty()
    }
    
    func saveStore(store: dollar_in_my_pocket.Store) -> RxSwift.Observable<dollar_in_my_pocket.Store> {
        return .empty()
    }
    
    func savePhoto(storeId: Int, photos: [UIImage]) -> RxSwift.Observable<[dollar_in_my_pocket.Image]> {
        return .empty()
    }
    
    func fetchStorePhotos(storeId: Int) -> RxSwift.Observable<[dollar_in_my_pocket.Image]> {
        return .empty()
    }
    
    func deletePhoto(photoId: Int) -> RxSwift.Observable<Void> {
        return .empty()
    }
    
    func updateStore(storeId: Int, updateStoreRequest: dollar_in_my_pocket.AddStoreRequest) -> RxSwift.Observable<dollar_in_my_pocket.StoreInfoResponse> {
        return .empty()
    }
    
    func fetchStoreDetail(storeId: Int, latitude: Double, longitude: Double, startDate: Date, endDate: Date) -> RxSwift.Observable<dollar_in_my_pocket.Store> {
        return .empty()
    }
    
    func fetchRegisteredStores(cursor: Int?, size: Int) -> RxSwift.Observable<dollar_in_my_pocket.Pagination<dollar_in_my_pocket.StoreWithVisitsResponse>> {
        return .empty()
    }
    
    func deleteStore(storeId: Int, deleteReasonType: dollar_in_my_pocket.DeleteReason) -> RxSwift.Observable<Void> {
        return .empty()
    }
    
    func fetchBossStore(bossStoreId: String, currentLocation: CLLocation) -> RxSwift.Observable<dollar_in_my_pocket.BossStore> {
        return .empty()
    }
}
