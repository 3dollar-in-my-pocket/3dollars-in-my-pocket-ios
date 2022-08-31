import Foundation

import RxSwift
import Alamofire

struct NetworkManager {
    func createGetObservable<T: Decodable>(
        class: T.Type,
        urlString: String,
        headers: HTTPHeaders,
        parameters: [String: Any]? = nil
    ) -> Observable<T> {
        return .create { observer in
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                parameters: parameters,
                headers: headers
            ).responseData { response in
                Log.debug(response)
                if response.isSuccess() {
                    observer.processValue(class: T.self, response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
}
