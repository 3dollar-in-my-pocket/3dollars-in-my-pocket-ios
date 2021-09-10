import Alamofire
import RxSwift

protocol FAQServiceProtocol {
  
  func getFAQs() -> Observable<[FAQResponse]>
}

struct FAQService: FAQServiceProtocol {
  func getFAQs() -> Observable<[FAQResponse]> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v2/faqs"
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .get,
        headers: HTTPUtils.defaultHeader()
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: [FAQResponse].self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
}
