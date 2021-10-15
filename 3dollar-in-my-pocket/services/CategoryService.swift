import Alamofire
import RxSwift
import CoreLocation

protocol CategoryServiceProtocol {
  
  func getStoreByDistance(
    category: StoreCategory,
    currentLocation: CLLocation,
    mapLocation: CLLocation?
  ) -> Observable<StoresGroupByDistanceResponse>
  
  func getStoreByReview(
    category: StoreCategory,
    currentLocation: CLLocation,
    mapLocation: CLLocation?
  ) -> Observable<StoresGroupByReviewResponse>
}

struct CategoryService: CategoryServiceProtocol {
  
  func getStoreByDistance(
    category: StoreCategory,
    currentLocation: CLLocation,
    mapLocation: CLLocation?
  ) -> Observable<StoresGroupByDistanceResponse> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v2/stores/distance"
      let headers = HTTPUtils.jsonHeader()
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
          observer.processValue(class: StoresGroupByDistanceResponse.self, response: response)
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
  ) -> Observable<StoresGroupByReviewResponse> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v2/stores/review"
      let headers = HTTPUtils.jsonHeader()
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
          observer.processValue(class: StoresGroupByReviewResponse.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      return Disposables.create()
    }
  }
}
