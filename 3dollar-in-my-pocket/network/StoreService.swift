import Alamofire
import RxSwift

struct StoreService {
  
  static func getStoreOrderByNearest(
    latitude: Double,
    longitude: Double
  ) -> Observable<[StoreCard]> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/get"
      let headers = HTTPUtils.defaultHeader()
      let parameters = ["latitude": latitude, "longitude": longitude]
      
      AF.request(urlString, method: .get, parameters: parameters, headers: headers)
        .responseJSON { response in
          if let value = response.value {
            if let storeCards: [StoreCard] = JsonUtils.toJson(object: value) {
              observer.onNext(storeCards)
              observer.onCompleted()
            } else {
              let error = CommonError(desc: "failed to json")
              
              observer.onError(error)
            }
          } else {
            let error = CommonError(desc: "response value is nil")
            
            observer.onError(error)
          }
        }
      
      return Disposables.create()
    }
  }
  
  static func saveStore(
    store: Store,
    images:[UIImage]
  ) -> Observable<SaveResponse> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/save"
      let headers = HTTPUtils.defaultHeader()
      var parameters = store.toJson()
      
      parameters["userId"] = "\(UserDefaultsUtil.getUserId()!)"
      parameters["menu"] = nil
      parameters["image"] = nil
      parameters["review"] = nil
      
      // 배열로 보냈을 경우 서버에서 못받아서 일단 임시로 필드처럼 해서 보냄 ㅠㅠ
      for index in store.menus.indices {
        let menu = store.menus[index]
        
        parameters["menu[\(index)].name"] = menu.name
        parameters["menu[\(index)].price"] = menu.price
      }
      
      AF.upload(multipartFormData: { (multipartFormData) in
        for index in images.indices {
          let image = images[index]
          
          multipartFormData.append(image.jpegData(compressionQuality: 0.5)!, withName: "image", fileName: "image\(index).jpeg", mimeType: "image/jpeg")
        }
        for (key, value) in parameters {
          let stringValue = String(describing: value)
          
          multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
        }
      }, to: urlString, headers: headers).responseJSON(completionHandler: { response in
        if let value = response.value {
          if let saveResponse: SaveResponse = JsonUtils.toJson(object: value) {
            observer.onNext(saveResponse)
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "failed to json")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "Response value is nil")
          
          observer.onError(error)
        }
      })
      return Disposables.create()
    }
  }
  
  static func updateStore(
    storeId: Int,
    store: Store,
    images: [UIImage]
  ) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/update"
      let headers = HTTPUtils.defaultHeader()
      var parameters = store.toJson()
      
      parameters["menu"] = nil
      parameters["image"] = nil
      parameters["review"] = nil
      parameters["storeId"] = storeId
      
      for index in store.menus.indices {
        let menu = store.menus[index]
        
        parameters["menu[\(index)].name"] = menu.name
        parameters["menu[\(index)].price"] = menu.price
      }
      
      AF.upload(multipartFormData: { (multipartFormData) in
        for index in images.indices {
          let image = images[index]
          
          multipartFormData.append(image.jpegData(compressionQuality: 0.5)!, withName: "image", fileName: "image\(index).jpeg", mimeType: "image/jpeg")
        }
        for (key, value) in parameters {
          let stringValue = String(describing: value)
          
          multipartFormData.append(stringValue.data(using: .utf8)!, withName: key)
        }
      }, to: urlString, method: .put, headers: headers).responseString(completionHandler: { response in
        if let statusCode = response.response?.statusCode {
          if statusCode == 200 {
            observer.onNext(response.value ?? "")
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "Status code: \(statusCode)")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "Status code is nil")
          
          observer.onError(error)
        }
      })
      return Disposables.create()
    }
  }
  
  static func getStoreDetail(
    storeId: Int,
    latitude: Double,
    longitude: Double
  ) -> Observable<Store> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/detail"
      let headers = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = [
        "storeId": storeId,
        "latitude": latitude,
        "longitude": longitude
      ]
      
      AF.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headers
      ).responseJSON { response in
        if let value = response.value {
          if let store: Store = JsonUtils.toJson(object: value) {
            observer.onNext(store)
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "failed to json")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "Response value is nil")
          
          observer.onError(error)
        }
      }
      
      return Disposables.create()
    }
  }
  
  static func getReportedStore(page: Int) -> Observable<Page<Store>> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/user"
      let headers = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = ["page": page, "userId": UserDefaultsUtil.getUserId()!]
      
      AF.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headers
      ).responseJSON { response in
        if let value = response.value {
          if let storePage: Page<Store> = JsonUtils.toJson(object: value) {
            observer.onNext(storePage)
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "failed to json")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "Response value is nil")
          
          observer.onError(error)
        }
      }
      
      return Disposables.create()
    }
  }
  
  static func deleteStore(
    storeId: Int,
    deleteReasonType: DeleteReason
  ) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/store/delete"
      let headers = HTTPUtils.defaultHeader()
      let parameters : [String: Any] = [
        "storeId": storeId,
        "userId": UserDefaultsUtil.getUserId()!,
        "deleteReasonType": deleteReasonType.getValue()
      ]
      
      AF.request(
        urlString,
        method: .delete,
        parameters: parameters,
        headers: headers
      ).responseString { response in
        if let statusCode = response.response?.statusCode {
          if statusCode == 200 {
            observer.onNext("success")
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "이미 삭제요청한 사람")
            
            observer.onError(error)
          }
        }
      }
      
      return Disposables.create()
    }
  }
}
