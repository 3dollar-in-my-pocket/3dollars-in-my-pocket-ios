import Foundation
import RxSwift

protocol PopupServiceProtocol {
    func fetchPopups() -> Observable<[PopupResponse]>
}

struct PopupService: PopupServiceProtocol {
    func fetchPopups() -> Observable<[PopupResponse]> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/api/v1/popups"
            let parameters: [String: Any] = ["platform": "IOS"]
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                parameters: parameters
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(class: [PopupResponse].self, response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            return Disposables.create()
        }
    }
}
