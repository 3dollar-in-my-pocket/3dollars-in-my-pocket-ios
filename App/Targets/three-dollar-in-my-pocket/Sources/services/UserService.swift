import Alamofire
import RxSwift

protocol UserServiceProtocol {
    @available(*, deprecated, message: "func fetchUser() -> Observable<User>를 사용해주세요.")
    func fetchUserInfo() -> Observable<UserInfoResponse>
    
    func fetchUser() -> Observable<User>
}

struct UserService: UserServiceProtocol {
    private let networkManager = NetworkManager()
    
    func fetchUserInfo() -> Observable<UserInfoResponse> {
        return Observable.create { observer -> Disposable in
            let urlString = HTTPUtils.url + "/api/v2/user/me"
            let headders = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headders
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(class: UserInfoResponse.self, response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchUser() -> Observable<User> {
        let urlString = HTTPUtils.url + "/api/v2/user/me"
        let headders = HTTPUtils.defaultHeader()
        
        return self.networkManager.createGetObservable(
            class: UserInfoResponse.self,
            urlString: urlString,
            headers: headders
        )
        .map(User.init(response:))
    }
}
