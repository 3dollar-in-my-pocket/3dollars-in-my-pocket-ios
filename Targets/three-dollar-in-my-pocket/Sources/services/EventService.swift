import Alamofire
import RxSwift

protocol EventServiceProtocol {
    func sendClickEvent(targetId: Int, targetType: String) -> Observable<String>
}

struct EventService: EventServiceProtocol {
    private let networkManager = NetworkManager()
    
    func sendClickEvent(targetId: Int, targetType: String) -> Observable<String> {
        let urlString = HTTPUtils.url + "/api/v1/event/click/\(targetType)/\(targetId)"
        let headers = HTTPUtils.defaultHeader()
        
        return self.networkManager.createPostObservable(
            class: String.self,
            urlString: urlString,
            headers: headers
        )
    }
}
