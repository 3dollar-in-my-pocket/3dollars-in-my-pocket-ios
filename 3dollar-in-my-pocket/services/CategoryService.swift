import Alamofire
import RxSwift
import CoreLocation

protocol CategoryServiceProtocol {
  
  func getStoreByDistance(
    category: StoreCategory,
    currentLocation: CLLocation,
    mapLocation: CLLocation?
  ) -> Observable<CategoryByDistance>
  
  func getStoreByReview(
    category: StoreCategory,
    currentLocation: CLLocation,
    mapLocation: CLLocation?
  ) -> Observable<CategoryByReview>
}

struct CategoryService: CategoryServiceProtocol {
  
  func getStoreByDistance(
    category: StoreCategory,
    currentLocation: CLLocation,
    mapLocation: CLLocation?
  ) -> Observable<CategoryByDistance> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/category/distance"
      let headers = HTTPUtils.defaultHeader()
      var parameters: [String: Any] = [
        "category": category.getValue(),
        "latitude": currentLocation.coordinate.latitude,
        "longitude": currentLocation.coordinate.longitude
      ]
      
      if let mapLocation = mapLocation {
        parameters["mapLatitude"] = mapLocation.coordinate.latitude
        parameters["mapLongitude"] = mapLocation.coordinate.longitude
      }
      
      HTTPUtils.defaultSession.request(
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
    currentLocation: CLLocation,
    mapLocation: CLLocation?
  ) -> Observable<CategoryByReview> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/category/review"
      let headers = HTTPUtils.defaultHeader()
      var parameters: [String: Any] = [
        "category": category.getValue(),
        "latitude": currentLocation.coordinate.latitude,
        "longitude": currentLocation.coordinate.longitude
      ]
      
      if let mapLocation = mapLocation {
        parameters["mapLatitude"] = mapLocation.coordinate.latitude
        parameters["mapLongitude"] = mapLocation.coordinate.longitude
      }
      
      HTTPUtils.defaultSession.request(
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
