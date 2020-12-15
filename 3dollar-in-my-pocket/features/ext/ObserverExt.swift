import RxSwift
import Alamofire

extension AnyObserver {
  
  func processHTTPError(statusCode: Int) {
    switch statusCode {
    case 401:
      self.onError(HTTPError.unauthorized)
    case 403:
      self.onError(HTTPError.forbidden)
    case 503:
      self.onError(HTTPError.maintenance)
    default:
      break
    }
  }
}
