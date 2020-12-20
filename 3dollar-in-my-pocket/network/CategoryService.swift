import Alamofire
import RxSwift

protocol CategoryServiceProtocol {
  func getStroeByDistance(
    category: StoreCategory,
    latitude: Double,
    longitude: Double
  ) -> Observable<CategoryByDistance>
  
  func getStoreByReview(
    category: StoreCategory,
    latitude: Double,
    longitude: Double
  ) -> Observable<CategoryByReview>
}

struct CategoryService: CategoryServiceProtocol {
  
  func getStroeByDistance(
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
        if response.isSuccess() {
          observer.processValue(class: CategoryByDistance.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      return Disposables.create()
    }
  }
  
  func getStoreByReview(
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
        if response.isSuccess() {
          observer.processValue(class: CategoryByReview.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      return Disposables.create()
    }
  }
}
