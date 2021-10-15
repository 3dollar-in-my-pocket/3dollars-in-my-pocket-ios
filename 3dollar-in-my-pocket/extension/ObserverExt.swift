import RxSwift
import Alamofire
import FirebaseCrashlytics

extension AnyObserver {
  
  func processHTTPError<T>(response: AFDataResponse<T>) {
    if let statusCode = response.response?.statusCode {
      if let httpError = HTTPError(rawValue: statusCode) {
        self.onError(httpError)
      } else {
        self.onError(BaseError.unknown)
      }
    } else {
      switch response.result {
      case .failure(let error):
        if error._code == 13 {
          self.onError(BaseError.timeout)
        }
      default:
        break
      }
    }
  }
  
  func processValue<T: Decodable>(class: T.Type, response: AFDataResponse<Any>) {
    if let value = response.value {
      if let responseContainer: ResponseContainer<T> = JsonUtils.toJson(object: value) {
        self.onNext(responseContainer.data as! Element)
        self.onCompleted()
      } else {
        self.onError(BaseError.failDecoding)
      }
    } else {
      self.onError(BaseError.nilValue)
    }
  }
  
  func processValue(data: Any?) {
    if let data = data {
      if let element = data as? Element {
        self.onNext(element)
        self.onCompleted()
      } else {
        self.onError(BaseError.failDecoding)
      }
    } else {
      self.onError(BaseError.nilValue)
    }
  }
}
