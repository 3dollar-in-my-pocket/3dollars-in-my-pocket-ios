import Foundation

import RxSwift

protocol AdvertisementServiceProtocol {
    func fetchAdvertisements(
        position: AdvertisementPosition
    ) -> Observable<[Advertisement]>
}

struct AdvertisementService: AdvertisementServiceProtocol {
    private let networkManager = NetworkManager()
    
    func fetchAdvertisements(
        position: AdvertisementPosition
    ) -> Observable<[Advertisement]> {
        let urlString = HTTPUtils.url + "/api/v1/advertisements"
        let parameters: [String: Any] = [
            "platform": "IOS",
            "position": position.rawValue
        ]
        
        return self.networkManager.createGetObservable(
            class: [AdvertisementResponse].self,
            urlString: urlString,
            headers: [:],
            parameters: parameters
        )
        .map { $0.map(Advertisement.init(response:)) }
    }
}
