import Alamofire
import RxSwift

protocol FAQServiceProtocol {
  
  func fetchFAQs(category: FAQCategory?) -> Observable<[FAQResponse]>
  
  func fetchFAQCategories() -> Observable<[FAQCategoryResponse]>
}

struct FAQService: FAQServiceProtocol {
  func fetchFAQs(category: FAQCategory?) -> Observable<[FAQResponse]> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v2/faqs"
      let headers = HTTPUtils.jsonHeader()
      var params: [String: Any] = [:]
      
      if let category = category {
        params["category"] = category.rawValue
      }
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .get,
        parameters: nil,
        headers: headers
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
  
  func fetchFAQCategories() -> Observable<[FAQCategoryResponse]> {
    return .create { observer in
      let urlString = HTTPUtils.url + "/api/v2/faq/categories"
      let header = HTTPUtils.jsonHeader()
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .get,
        headers: header
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: [FAQCategoryResponse].self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
}
