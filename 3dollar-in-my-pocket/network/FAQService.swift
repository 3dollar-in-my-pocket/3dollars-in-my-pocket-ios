import Alamofire
import RxSwift

protocol FAQServiceProtocol {
  func getFAQs() -> Observable<[FAQ]>
}

struct FAQService: FAQServiceProtocol {
  func getFAQs() -> Observable<[FAQ]> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/faqs"
      
      AF.request(
        urlString,
        method: .get,
        headers: HTTPUtils.defaultHeader()
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: [FAQ].self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
}
