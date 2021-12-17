import Alamofire
import RxSwift

protocol ReviewServiceProtocol {
  
  func saveReview(review: Review, storeId: Int) -> Observable<ReviewInfoResponse>
  
  func modifyReview(review: Review) -> Observable<ReviewInfoResponse>
  
  func deleteReview(reviewId: Int) -> Observable<Void>
  
  func fetchMyReviews(cursor: Int?, size: Int) -> Observable<Pagination<ReviewDetailResponse>>
}

struct ReviewService: ReviewServiceProtocol {
  
  func saveReview(review: Review, storeId: Int) -> Observable<ReviewInfoResponse> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v2/store/review"
      let headers = HTTPUtils.jsonWithTokenHeader()
      var parameter = AddReviewRequest(review: review).params
      parameter["storeId"] = storeId
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .post,
        parameters: parameter,
        encoding: JSONEncoding.default,
        headers: headers
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: ReviewInfoResponse.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
  
  func modifyReview(review: Review) -> Observable<ReviewInfoResponse> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v2/store/review/\(review.reviewId)"
      let headers = HTTPUtils.defaultHeader()
      let parameter = UpdateReviewRequest(review: review).params
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .put,
        parameters: parameter,
        encoding: JSONEncoding.default,
        headers: headers
      )
      .responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: ReviewInfoResponse.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
  
  func deleteReview(reviewId: Int) -> Observable<Void> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v2/store/review/\(reviewId)"
      let headers = HTTPUtils.defaultHeader()
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .delete,
        headers: headers
      ).responseJSON { response in
        if let statusCode = response.response?.statusCode {
          if "\(statusCode)".first! == "2" {
            observer.onNext(())
            observer.onCompleted()
          }
        }
        observer.processHTTPError(response: response)
      }
      
      return Disposables.create()
    }
  }
  
    func fetchMyReviews(cursor: Int?, size: Int) -> Observable<Pagination<ReviewDetailResponse>> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v3/store/reviews/me"
      let headers = HTTPUtils.defaultHeader()
      var parameters: [String: Any] = ["size": size]
      
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
          observer.processValue(class: Pagination<ReviewDetailResponse>.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      return Disposables.create()
    }
  }
}
