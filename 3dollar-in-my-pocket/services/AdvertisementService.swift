import Foundation

import RxSwift

protocol AdvertisementServiceProtocol {
    func fetchAdvertisements(
        position: AdvertisementPosition
    ) -> Observable<[AdvertisementResponse]>
}

struct AdvertisementService: AdvertisementServiceProtocol {
    func fetchAdvertisements(
        position: AdvertisementPosition
    ) -> Observable<[AdvertisementResponse]> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/api/v1/advertisements"
            let parameters: [String: Any] = [
                "platform": "IOS",
                "position": position.rawValue
            ]
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                parameters: parameters
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(class: [AdvertisementResponse].self, response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            return Disposables.create()
        }
    }
}
