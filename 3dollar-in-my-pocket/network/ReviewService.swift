import Alamofire
import RxSwift

struct ReviewService {
  
  static func saveReview(
    review: Review,
    storeId: Int
  ) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/review/save?storeId=\(storeId)&userId=\(UserDefaultsUtil.getUserId()!)"
      let headers = HTTPUtils.jsonWithTokenHeader()
      let parameter = review.toJson()
      
      AF.request(
        urlString,
        method: .post,
        parameters: parameter,
        encoding: JSONEncoding.default,
        headers: headers
      ).responseString { response in
        if let statusCode = response.response?.statusCode {
          if statusCode == 200 {
            observer.onNext("success")
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "fail to save review")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "status code is nil")
          
          observer.onError(error)
        }
      }
      
      return Disposables.create()
    }
  }
  
  static func getMyReview(page: Int) -> Observable<Page<Review>> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/review/user"
      let headers = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = ["page": page, "userId": UserDefaultsUtil.getUserId()!]
      
      AF.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headers
      ).responseJSON { response in
        if let value = response.value {
          if let reviewPage: Page<Review> = JsonUtils.toJson(object: value) {
            observer.onNext(reviewPage)
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
