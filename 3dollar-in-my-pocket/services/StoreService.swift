import Alamofire
import RxSwift

import CoreLocation

protocol StoreServiceProtocol {
    
    func searchNearStores(
        currentLocation: CLLocation,
        mapLocation: CLLocation,
        distance: Double,
        category: StoreCategory?,
        orderType: StoreOrder?
    ) -> Observable<[StoreWithVisitsAndDistanceResponse]>
    
    func saveStore(store: Store) -> Observable<Store>
    
    func savePhoto(storeId: Int, photos: [UIImage]) -> Observable<[StoreImageResponse]>
    
    func getPhotos(storeId: Int) -> Observable<[StoreImageResponse]>
    
    func deletePhoto(photoId: Int) -> Observable<String>
    
    func updateStore(
        storeId: Int,
        updateStoreRequest: AddStoreRequest
    ) -> Observable<StoreInfoResponse>
    
    func getStoreDetail(
        storeId: Int,
        latitude: Double,
        longitude: Double,
        startDate: Date,
        endDate: Date
    ) -> Observable<StoreDetailResponse>
    
    func fetchRegisteredStores(
        cursor: Int?,
        size: Int
    ) -> Observable<Pagination<StoreWithVisitsResponse>>
    
    func deleteStore(
        storeId: Int,
        deleteReasonType: DeleteReason
    ) -> Observable<StoreDeleteResponse>
}


struct StoreService: StoreServiceProtocol {
    
    func searchNearStores(
        currentLocation: CLLocation,
        mapLocation: CLLocation,
        distance: Double,
        category: StoreCategory?,
        orderType: StoreOrder?
    ) -> Observable<[StoreWithVisitsAndDistanceResponse]> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/api/v2/stores/near"
            let headers = HTTPUtils.defaultHeader()
            var parameters: [String: Any] = [
                "distance": distance,
                "latitude": currentLocation.coordinate.latitude,
                "longitude": currentLocation.coordinate.longitude,
                "mapLatitude": mapLocation.coordinate.latitude,
                "mapLongitude": mapLocation.coordinate.longitude
            ]
            
            if let category = category {
                parameters["category"] = category.rawValue
            }
            
            if let orderType = orderType {
                parameters["orderType"] = orderType.rawValue
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
    
    func savePhoto(storeId: Int, photos: [UIImage]) -> Observable<[StoreImageResponse]> {
        return Observable.create { observer -> Disposable in
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
            .responseJSON(completionHandler: { response in
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
    
    func getStoreDetail(
        storeId: Int,
        latitude: Double,
        longitude: Double,
        startDate: Date,
        endDate: Date
    ) -> Observable<StoreDetailResponse> {
        return Observable.create { observer -> Disposable in
            let urlString = HTTPUtils.url + "/api/v2/store"
            let headers = HTTPUtils.defaultHeader()
            let parameters: [String: Any] = [
                "storeId": storeId,
                "latitude": latitude,
                "longitude": longitude,
                "startDate": startDate.toString(format: "yyyy-MM-dd"),
                "endDate": endDate.toString(format: "yyyy-MM-dd")
            ]
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                parameters: parameters,
                headers: headers
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(class: StoreDetailResponse.self, response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
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
    ) -> Observable<StoreDeleteResponse> {
        return Observable.create { observer -> Disposable in
            let urlString = HTTPUtils.url + "/api/v2/store/\(storeId)"
            let headers = HTTPUtils.defaultHeader()
            let parameters: [String: Any] = ["deleteReasonType": deleteReasonType.getValue()]
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .delete,
                parameters: parameters,
                headers: headers
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(class: StoreDeleteResponse.self, response: response)
                } else if response.response?.statusCode == 409 {
                    let error = CommonError(desc: "store_delete_already_request".localized)
                    
                    observer.onError(error)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
}
