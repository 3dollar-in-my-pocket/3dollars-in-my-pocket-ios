import UIKit

import Alamofire
import RxSwift

import CoreLocation

protocol StoreServiceProtocol {
    @available(*, deprecated, message: "프로토콜화 시킨 함수로 이용 부탁드립니다.")
    func searchNearStores(
        currentLocation: CLLocation?,
        mapLocation: CLLocation,
        distance: Double,
        category: StreetFoodStoreCategory?,
        orderType: StoreOrder?
    ) -> Observable<[StoreWithVisitsAndDistanceResponse]>
    
    func searchNearStores(
        categoryId: String?,
        distance: Double?,
        currentLocation: CLLocation,
        mapLocation: CLLocation,
        orderType: StoreOrder?
    ) -> Observable<[StoreProtocol]>
    
    func searchNearBossStores(
        categoryId: String?,
        distance: Double?,
        currentLocation: CLLocation,
        mapLocation: CLLocation,
        orderType: BossStoreOrderType?
    ) -> Observable<[StoreProtocol]>
    
    func isStoresExistedAround(
        distance: Double,
        mapLocation: CLLocation
    ) -> Observable<CheckExistStoresNearbyResponse>
    
    func saveStore(store: Store) -> Observable<Store>
    
    func savePhoto(storeId: Int, photos: [UIImage]) -> Observable<[Image]>
    
    func getPhotos(storeId: Int) -> Observable<[StoreImageResponse]>
    
    func deletePhoto(photoId: Int) -> Observable<String>
    
    func updateStore(
        storeId: Int,
        updateStoreRequest: AddStoreRequest
    ) -> Observable<StoreInfoResponse>
    
    func fetchStoreDetail(
        storeId: Int,
        latitude: Double,
        longitude: Double,
        startDate: Date,
        endDate: Date
    ) -> Observable<Store>
    
    func fetchRegisteredStores(
        cursor: Int?,
        size: Int
    ) -> Observable<Pagination<StoreWithVisitsResponse>>
    
    func deleteStore(
        storeId: Int,
        deleteReasonType: DeleteReason
    ) -> Observable<Void>
    
    func fetchBossStore(
        bossStoreId: String,
        currentLocation: CLLocation
    ) -> Observable<BossStore>
}


struct StoreService: StoreServiceProtocol {
    let networkManager = NetworkManager()
    
    func searchNearStores(
        currentLocation: CLLocation?,
        mapLocation: CLLocation,
        distance: Double,
        category: StreetFoodStoreCategory?,
        orderType: StoreOrder?
    ) -> Observable<[StoreWithVisitsAndDistanceResponse]> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/api/v2/stores/near"
            let headers = HTTPUtils.defaultHeader()
            var parameters: [String: Any] = [
                "distance": distance,
                "mapLatitude": mapLocation.coordinate.latitude,
                "mapLongitude": mapLocation.coordinate.longitude
            ]
            
            if let category = category {
                parameters["category"] = category.rawValue
            }
            
            if let orderType = orderType {
                parameters["orderType"] = orderType.rawValue
            }
            
            if let currentLocation = currentLocation {
                parameters["latitude"] = currentLocation.coordinate.latitude
                parameters["longitude"] = currentLocation.coordinate.longitude
            }
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                parameters: parameters,
                headers: headers
            )
            .responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(
                        class: [StoreWithVisitsAndDistanceResponse].self,
                        response: response
                    )
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func searchNearStores(
        categoryId: String?,
        distance: Double?,
        currentLocation: CLLocation,
        mapLocation: CLLocation,
        orderType: StoreOrder?
    ) -> Observable<[StoreProtocol]> {
        let urlString = HTTPUtils.url + "/api/v2/stores/near"
        let headers = HTTPUtils.defaultHeader()
        var parameters: [String: Any] = [
            "mapLatitude": mapLocation.coordinate.latitude,
            "mapLongitude": mapLocation.coordinate.longitude,
            "latitude": currentLocation.coordinate.latitude,
            "longitude": currentLocation.coordinate.longitude
        ]
        
        if let distance = distance {
            parameters["distance"] = distance
        }
        
        if let categoryId = categoryId {
            parameters["category"] = categoryId
        }
        
        if let orderType = orderType {
            parameters["orderType"] = orderType.rawValue
        }
        
        return self.networkManager.createGetObservable(
            class: [StoreWithVisitsAndDistanceResponse].self,
            urlString: urlString,
            headers: headers,
            parameters: parameters
        )
        .map { $0.map(Store.init(response: )) }
    }
    
    func searchNearBossStores(
        categoryId: String?,
        distance: Double?,
        currentLocation: CLLocation,
        mapLocation: CLLocation,
        orderType: BossStoreOrderType?
    ) -> Observable<[StoreProtocol]> {
        let urlString = HTTPUtils.url + "/api/v1/boss/stores/around"
        let headers = HTTPUtils.jsonHeader()
        var parameters: [String: Any] = [
            "latitude": currentLocation.coordinate.latitude,
            "longitude": currentLocation.coordinate.longitude,
            "mapLatitude": mapLocation.coordinate.latitude,
            "mapLongitude": mapLocation.coordinate.longitude
        ]
        
        if let categoryId = categoryId {
            parameters["categoryId"] = categoryId
        }
        if let distance = distance {
            parameters["distanceKm"] = distance
        }
        if let orderType = orderType {
            parameters["orderType"] = orderType.rawValue
        }
        
        return self.networkManager.createGetObservable(
            class: [BossStoreAroundInfoResponse].self,
            urlString: urlString,
            headers: headers,
            parameters: parameters
        )
        .map { $0.map(BossStore.init(response: )) }
    }
    
    func isStoresExistedAround(
        distance: Double,
        mapLocation: CLLocation
    ) -> Observable<CheckExistStoresNearbyResponse> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/api/v1/stores/near/exists"
            let header = HTTPUtils.jsonHeader()
            let parameters: [String: Any] = [
                "distance": distance,
                "mapLatitude": mapLocation.coordinate.latitude,
                "mapLongitude": mapLocation.coordinate.longitude
            ]
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                parameters: parameters,
                headers: header
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(
                        class: CheckExistStoresNearbyResponse.self,
                        response: response
                    )
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func saveStore(store: Store) -> Observable<Store> {
        let addStoreRequest = AddStoreRequest(store: store)
        
        return Observable.create { observer -> Disposable in
            let urlString = HTTPUtils.url + "/api/v2/store"
            let headers = HTTPUtils.defaultHeader()
            let parameters = addStoreRequest.params
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            ).responseJSON { response in
                if response.isSuccess() {
                    guard let storeInfoResponse = response.decode(class: StoreInfoResponse.self) else {
                        return  observer.onError(BaseError.failDecoding)
                    }
                    let store = Store(response: storeInfoResponse)
                    
                    observer.processValue(data: store)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            return Disposables.create()
        }
    }
    
    func savePhoto(storeId: Int, photos: [UIImage]) -> Observable<[Image]> {
        return Observable<[StoreImageResponse]>.create { observer -> Disposable in
            let urlString = HTTPUtils.url + "/api/v2/store/images"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.fileUploadSession.upload(
                multipartFormData: { multipartFormData in
                    for data in ImageUtils.dataArrayFromImages(photos: photos) {
                        multipartFormData.append(
                            data,
                            withName: "images",
                            fileName: "image.jpeg",
                            mimeType: "image/jpeg"
                        )
                    }
                    multipartFormData.append("\(storeId)".data(using: .utf8)!, withName: "storeId")
                },
                to: urlString,
                headers: headers
            )
            .responseData(completionHandler: { response in
                if let statusCode = response.response?.statusCode {
                    if "\(statusCode)".first! == "2" {
                        observer.processValue(class: [StoreImageResponse].self, response: response)
                    }
                } else {
                    observer.processHTTPError(response: response)
                }
            })
            
            return Disposables.create()
        }
        .map { $0.map(Image.init(response:)) }
    }
    
    func getPhotos(storeId: Int) -> Observable<[StoreImageResponse]> {
        return Observable.create { observer -> Disposable in
            let urlString = HTTPUtils.url + "/api/v2/store/\(storeId)/images"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headers
            )
            .responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(class: [StoreImageResponse].self, response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func deletePhoto(photoId: Int) -> Observable<String> {
        return Observable.create { observer -> Disposable in
            let urlString = HTTPUtils.url + "/api/v2/store/image/\(photoId)"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .delete,
                headers: headers
            )
            .responseString { response in
                if let statusCode = response.response?.statusCode {
                    if "\(statusCode)".first! == "2" {
                        observer.onNext("success")
                        observer.onCompleted()
                    }
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func updateStore(
        storeId: Int,
        updateStoreRequest: AddStoreRequest
    ) -> Observable<StoreInfoResponse> {
        return Observable.create { observer -> Disposable in
            let urlString = HTTPUtils.url + "/api/v2/store/\(storeId)"
            let headers = HTTPUtils.defaultHeader()
            let parameters = updateStoreRequest.params
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .put,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(class: StoreInfoResponse.self, response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchStoreDetail(
        storeId: Int,
        latitude: Double,
        longitude: Double,
        startDate: Date,
        endDate: Date
    ) -> Observable<Store> {
        let urlString = HTTPUtils.url + "/api/v2/store"
        let headers = HTTPUtils.defaultHeader()
        let parameters: [String: Any] = [
            "storeId": storeId,
            "latitude": latitude,
            "longitude": longitude,
            "startDate": startDate.toString(format: "yyyy-MM-dd"),
            "endDate": endDate.toString(format: "yyyy-MM-dd")
        ]
        
        return self.networkManager.createGetObservable(
            class: StoreDetailResponse.self,
            urlString: urlString,
            headers: headers,
            parameters: parameters
        )
        .map(Store.init(response:))
    }
    
    func fetchRegisteredStores(
        cursor: Int?,
        size: Int
    ) -> Observable<Pagination<StoreWithVisitsResponse>> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/api/v3/stores/me"
            let headers = HTTPUtils.defaultHeader()
            var parameters: [String: Any] = [
                "size": 20
            ]
            
            if let cursor = cursor {
                parameters["cursor"] = cursor
            }
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                parameters: parameters,
                headers: headers
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(
                        class: Pagination<StoreWithVisitsResponse>.self,
                        response: response
                    )
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
    
    func deleteStore(
        storeId: Int,
        deleteReasonType: DeleteReason
    ) -> Observable<Void> {
        let urlString = HTTPUtils.url + "/api/v2/store/\(storeId)"
        let headers = HTTPUtils.defaultHeader()
        let parameters: [String: Any] = ["deleteReasonType": deleteReasonType.getValue()]
        
        return self.networkManager.createDeleteObservable(
            urlString: urlString,
            parameters: parameters,
            headers: headers
        )
    }
    
    func fetchBossStore(
        bossStoreId: String,
        currentLocation: CLLocation
    ) -> Observable<BossStore> {
        let urlString = HTTPUtils.url + "/api/v1/boss/store/\(bossStoreId)/detail"
        let headers = HTTPUtils.defaultHeader()
        let parameters: [String: Any] = [
            "latitude": currentLocation.coordinate.latitude,
            "longitude": currentLocation.coordinate.longitude
        ]
        
        return self.networkManager.createGetObservable(
            class: BossStoreWithFeedbacksResponse.self,
            urlString: urlString,
            headers: headers,
            parameters: parameters
        )
        .map(BossStore.init(response:))
    }
}
