import Foundation

import RxSwift
import Alamofire

extension AnyObserver {
    func processHTTPError<T>(response: AFDataResponse<T>) {
        if let statusCode = response.response?.statusCode {
            if let httpError = HTTPError(rawValue: statusCode) {
                self.onError(httpError)
            } else {
                if let value = response.value {
                    print(value)
                    if let responseContainer: ResponseContainer<String?>
                        = JsonUtils.toJson(object: value) {
                        self.onError(BaseError.custom(responseContainer.message))
                    }
                } else {
                    self.onError(BaseError.unknown)
                }
            }
        } else {
            switch response.result {
            case .failure(let error):
                if error._code == 13 {
                    self.onError(BaseError.timeout)
                } else {
                    self.onError(error)
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
    
    func processValue<T: Decodable>(class: T.Type, response: AFDataResponse<Data>) {
        if let data = response.value {
            if let responseContainer: ResponseContainer<T> = JsonUtils.decode(data: data) {
                let element = responseContainer.data as! Element
                self.onNext(element)
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
    
    func processAPIError(response: AFDataResponse<Data>) {
        if let value = response.value,
           let errorContainer: ResponseContainer<String> = JsonUtils.decode(data: value) {
            self.onError(BaseError.custom(errorContainer.message))
        } else {
            self.processHTTPError(response: response)
        }
    }
}
