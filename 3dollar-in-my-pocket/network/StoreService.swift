import Alamofire
import RxSwift

protocol StoreServiceProtocol {
  
  func getStoreOrderByNearest(latitude: Double, longitude: Double) -> Observable<[StoreCard]>
  
  func saveStore(store: Store) -> Observable<SaveResponse>
  
  func savePhoto(storeId: Int, photos: [UIImage]) -> Observable<String>
  
  func getPhotos(storeId: Int) -> Observable<[Image]>
  
  func deletePhoto(storeId: Int, photoId: Int) -> Observable<String>
  
  func updateStore(storeId: Int, store: Store) -> Observable<String>
  
  func getStoreDetail(storeId: Int, latitude: Double, longitude: Double) -> Observable<Store>
  
  func getReportedStore(page: Int) -> Observable<Page<Store>>
  
  func deleteStore(storeId: Int, deleteReasonType: DeleteReason) -> Observable<String>
}


struct StoreService: StoreServiceProtocol {
  
  func getStoreOrderByNearest(latitude: Double, longitude: Double) -> Observable<[StoreCard]> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/get"
      let headers = HTTPUtils.defaultHeader()
      let parameters = ["latitude": latitude, "longitude": longitude]
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headers
      )
        .responseJSON { response in
          if response.isSuccess() {
            observer.processValue(class: [StoreCard].self, response: response)
          } else {
            observer.processHTTPError(response: response)
          }
        }
      
      return Disposables.create()
    }
  }
  
  func saveStore(store: Store) -> Observable<SaveResponse> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/save"
      let headers = HTTPUtils.defaultHeader()
      var parameters = store.toJson()
      
      parameters["userId"] = "\(UserDefaultsUtil.getUserId()!)"
      
      for index in store.menus.indices {
        let menu = store.menus[index]
        
        parameters["menu[\(index)].category"] = menu.category?.rawValue ?? StoreCategory.BUNGEOPPANG
        parameters["menu[\(index)].name"] = menu.name
        parameters["menu[\(index)].price"] = menu.price
      }
      
      HTTPUtils.fileUploadSession.upload(multipartFormData: { multipartFormData in
        for (key, value) in parameters {
          let stringValue = String(describing: value)
          
          multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
        }
      }, to: urlString, headers: headers).responseJSON(completionHandler: { response in
        if response.isSuccess() {
          observer.processValue(class: SaveResponse.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      })
      return Disposables.create()
    }
  }
  
  func savePhoto(storeId: Int, photos: [UIImage]) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/\(storeId)/images"
      let headers = HTTPUtils.defaultHeader()
      
      HTTPUtils.fileUploadSession.upload(
        multipartFormData: { multipartFormData in
          for data in ImageUtils.dataArrayFromImages(photos: photos) {
            multipartFormData.append(
              data,
              withName: "image",
              fileName: "image.jpeg",
              mimeType: "image/jpeg"
            )
          }
          multipartFormData.append("\(storeId)".data(using: .utf8)!, withName: "storeId")
        },
        to: urlString,
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
  
  func getPhotos(storeId: Int) -> Observable<[Image]> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/\(storeId)/images"
      let headers = HTTPUtils.defaultHeader()
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .get,
        headers: headers
      )
      .responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: [Image].self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
  
  func deletePhoto(storeId: Int, photoId: Int) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/\(storeId)/images/\(photoId)"
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
  
  func updateStore(storeId: Int, store: Store) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/update"
      let headers = HTTPUtils.defaultHeader()
      var parameters = store.toJson()
      
      parameters["storeId"] = storeId
      
      for index in store.menus.indices {
        let menu = store.menus[index]
        
        parameters["menu[\(index)].category"] = menu.category?.rawValue ?? StoreCategory.BUNGEOPPANG
        parameters["menu[\(index)].name"] = menu.name
        parameters["menu[\(index)].price"] = menu.price
      }
      
      HTTPUtils.fileUploadSession.upload(multipartFormData: { multipartFormData in
        for (key, value) in parameters {
          let stringValue = String(describing: value)
          
          multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
        }
      }, to: urlString, method: .put, headers: headers).responseString(completionHandler: { response in
        if response.isSuccess() {
          observer.onNext("success")
          observer.onCompleted()
        } else {
          observer.processHTTPError(response: response)
        }
      })
      return Disposables.create()
    }
  }
  
  func getStoreDetail(storeId: Int, latitude: Double, longitude: Double) -> Observable<Store> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/detail"
      let headers = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = [
        "storeId": storeId,
        "latitude": latitude,
        "longitude": longitude
      ]
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headers
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: Store.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
  
  func getReportedStore(page: Int) -> Observable<Page<Store>> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/user"
      let headers = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = ["page": page]
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headers
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: Page<Store>.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
  
  func deleteStore(storeId: Int, deleteReasonType: DeleteReason) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/delete"
      let headers = HTTPUtils.defaultHeader()
      let parameters : [String: Any] = [
        "storeId": storeId,
        "userId": UserDefaultsUtil.getUserId()!,
        "deleteReasonType": deleteReasonType.getValue()
      ]
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .delete,
        parameters: parameters,
        headers: headers
      ).responseString { response in
        if response.isSuccess() {
          observer.onNext("success")
          observer.onCompleted()
        } else if response.response?.statusCode == 400 {
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
