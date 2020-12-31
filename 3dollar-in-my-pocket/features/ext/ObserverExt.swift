import RxSwift
import Alamofire
import FirebaseCrashlytics

extension AnyObserver {
  
  func processHTTPError<T>(response: AFDataResponse<T>) {
    let requestURL = response.request?.url?.absoluteURL.absoluteString ?? ""
    let value = response.value as? String ?? ""
    
    if let statusCode = response.response?.statusCode {
      if let httpError = HTTPError(rawValue: statusCode) {
        Crashlytics.crashlytics().record(error: httpError)
        Crashlytics.crashlytics().log(
          format: "http_error_undefiend".localized,
          arguments: getVaList(["\(statusCode)", requestURL, value])
        )
        self.onError(httpError)
      } else {
        let error = CommonError(desc: "error_unknown".localized)
        
        Crashlytics.crashlytics().record(error: error)
        Crashlytics.crashlytics().log(
          format: "http_error_undefiend".localized,
          arguments: getVaList(["\(statusCode)", requestURL, value])
        )
        self.onError(error)
      }
    } else {
      switch response.result {
      case .failure(let error):
        if error._code == 13 {
          let error = CommonError(desc: "http_error_timeout".localized)
          
          Crashlytics.crashlytics().record(error: error)
          Crashlytics.crashlytics().log(
            format: "http_error_undefiend".localized,
            arguments: getVaList(["\(-1)", requestURL, value])
          )
          self.onError(error)
        }
      default:
        break
      }
    }
  }
  
  func processValue<T: Decodable>(class: T.Type , response: AFDataResponse<Any>){
    if let value = response.value {
      if let valueObject: T = JsonUtils.toJson(object: value) {
        self.onNext(valueObject as! Element)
        self.onCompleted()
      } else {
        let error = CommonError(desc: "error_failed_to_json".localized)
        
        self.onError(error)
      }
    } else {
      if let urlString = response.request?.url?.absoluteString {
        Crashlytics.crashlytics().log(
          format: "error_crashlytics_format".localized,
          arguments: getVaList([urlString, "value is nil"])
        )
      }
      let error = CommonError(desc: "error_value_is_nil".localized)
      
      self.onError(error)
    }
  }
}
