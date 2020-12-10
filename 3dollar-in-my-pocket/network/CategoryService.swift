import Alamofire
import RxSwift

struct CategoryService: APIServiceType {
  
  static func getStroeByDistance(
    category: StoreCategory,
    latitude: Double,
    longitude: Double
  ) -> Observable<CategoryByDistance> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/category/distance"
      let headers = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = [
        "category": category.getValue(),
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
          if let categoryByDistance: CategoryByDistance = JsonUtils.toJson(object: value) {
            observer.onNext(categoryByDistance)
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "failed to json")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "value is nil")
          
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  static func getStoreByReview(
    category: StoreCategory,
    latitude: Double,
    longitude: Double
  ) -> Observable<CategoryByReview> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/category/review"
      let headers = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = [
        "category": category.getValue(),
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
          if let categoryByReview: CategoryByReview = JsonUtils.toJson(object: value) {
            observer.onNext(categoryByReview)
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "failed to json")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "value is nil")
          
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
}
