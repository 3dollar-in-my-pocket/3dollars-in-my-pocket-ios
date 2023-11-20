import Alamofire

import RxSwift

protocol ReviewServiceProtocol {
    func saveReview(review: Review) -> Observable<Review>
  
    func modifyReview(review: Review) -> Observable<Review>
  
  func deleteReview(reviewId: Int) -> Observable<Void>
  
  func fetchMyReviews(cursor: Int?, size: Int) -> Observable<Pagination<ReviewDetailResponse>>
}

struct ReviewService: ReviewServiceProtocol {
    private let networkManager = NetworkManager()
  
    func saveReview(review: Review) -> Observable<Review> {
        let urlString = HTTPUtils.url + "/api/v2/store/review"
        let headers = HTTPUtils.jsonWithTokenHeader()
        
        return self.networkManager.createPostObservable(
            class: ReviewInfoResponse.self,
            urlString: urlString,
            headers: headers,
            parameters: [
                "contents": review.contents,
                "rating": review.rating,
                "storeId": review.store.id
            ]
        )
        .map(Review.init(response:))
    }
  
    func modifyReview(review: Review) -> Observable<Review> {
        let urlString = HTTPUtils.url + "/api/v2/store/review/\(review.reviewId)"
        let headers = HTTPUtils.defaultHeader()
        
        return self.networkManager.createPutObservable(
            class: ReviewInfoResponse.self,
            urlString: urlString,
            headers: headers,
            parameters: [
                "contents": review.contents,
                "rating": review.rating
            ]
        )
        .map(Review.init(response:))
    }
  
    func deleteReview(reviewId: Int) -> Observable<Void> {
        let urlString = HTTPUtils.url + "/api/v2/store/review/\(reviewId)"
        let headers = HTTPUtils.defaultHeader()
        
        return self.networkManager.createDeleteObservable(
            urlString: urlString,
            headers: headers
        )
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
