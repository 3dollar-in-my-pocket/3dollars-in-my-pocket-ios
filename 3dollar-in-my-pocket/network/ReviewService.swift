import Alamofire
import RxSwift

protocol ReviewServiceProtocol {
  
  func saveReview(review: Review, storeId: Int) -> Observable<String>
  
  func getMyReview(page: Int) -> Observable<Page<Review>>
}

struct ReviewService: ReviewServiceProtocol {
  
  func saveReview(review: Review, storeId: Int) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/review/save?storeId=\(storeId)&userId=\(UserDefaultsUtil.getUserId()!)"
      let headers = HTTPUtils.jsonWithTokenHeader()
      let parameter = review.toJson()
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .post,
        parameters: parameter,
        encoding: JSONEncoding.default,
        headers: headers
      ).responseString { response in
        if response.isSuccess() {
          observer.onNext("success")
          observer.onCompleted()
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
  
  func getMyReview(page: Int) -> Observable<Page<Review>> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/review/user"
      let headers = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = ["page": page, "userId": UserDefaultsUtil.getUserId()!]
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headers
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: Page<Review>.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      return Disposables.create()
    }
  }
}
