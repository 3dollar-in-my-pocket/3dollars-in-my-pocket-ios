import Alamofire
import RxSwift

protocol FAQServiceProtocol {
  func getFAQs() -> Observable<[FAQ]>
}

struct FAQService: FAQServiceProtocol {
  func getFAQs() -> Observable<[FAQ]> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/faqs"
      
      Alamofire.request(
        urlString,
        method: .get,
        headers: HTTPUtils.defaultHeader()
      ).responseJSON { response in
        if let value = response.value {
          if let faqs: [FAQ] = JsonUtils.toJson(object: value) {
            observer.onNext(faqs)
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "failed to json")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "Value is nil")
          
          observer.onError(error)
        }
      }
      
      return Disposables.create()
    }
  }
}
