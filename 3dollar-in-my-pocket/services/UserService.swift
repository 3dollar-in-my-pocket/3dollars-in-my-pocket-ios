import Alamofire
import RxSwift

protocol UserServiceProtocol {
    func signin(request: SigninRequest) -> Observable<SigninResponse>
    
    func signinAnonymous() -> Observable<SigninResponse>
    
    func signup(request: SignupRequest) -> Observable<SigninResponse>
    
    func connectAccount(request: SigninRequest) -> Observable<String>
    
    func signout() -> Observable<Void>
    
    func editNickname(name: String) -> Observable<Void>
    
    @available(*, deprecated, message: "func fetchUser() -> Observable<User>를 사용해주세요.")
    func fetchUserInfo() -> Observable<UserInfoResponse>
    
    func fetchUser() -> Observable<User>
    
    func fetchUserActivity() -> Observable<User>
    
    func changeMarketingConsent(marketingConsentType: MarketingConsentType) -> Observable<String>
}

struct UserService: UserServiceProtocol {
    private let networkManager = NetworkManager()
    
    func signin(request: SigninRequest) -> Observable<SigninResponse> {
        let urlString = HTTPUtils.url + "/api/v2/login"
        let parameters = request.params
        let headers = HTTPUtils.jsonHeader()
        
        return self.networkManager.createPostObservable(
            class: SigninResponse.self,
            urlString: urlString,
            headers: headers,
            parameters: parameters
        )
    }
    
    func signinAnonymous() -> Observable<SigninResponse> {
        let urlString = HTTPUtils.url + "/api/v1/signup/anonymous"
        let headers = HTTPUtils.jsonHeader()
        
        return self.networkManager.createPostObservable(
            class: SigninResponse.self,
            urlString: urlString,
            headers: headers
        )
    }
    
    func signup(request: SignupRequest) -> Observable<SigninResponse> {
        return Observable.create { observer in
            let urlString = HTTPUtils.url + "/api/v2/signup"
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .post,
                parameters: request.parameters,
                encoding: JSONEncoding.default,
                headers: HTTPUtils.jsonHeader()
            ).responseData { response in
                if response.isSuccess() {
                    observer.processValue(class: SigninResponse.self, response: response)
                } else {
                    if response.response?.statusCode == 409 {
                        observer.onError(SignupError.alreadyExistedNickname)
                    } else if response.response?.statusCode == 400 {
                        observer.onError(SignupError.badRequest)
                    } else {
                        observer.processHTTPError(response: response)
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    func connectAccount(request: SigninRequest) -> Observable<String> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/api/v1/connect/account"
            let headers = HTTPUtils.defaultHeader()
            let params = request.params
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .put,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: headers
            ).responseData { response in
                if response.isSuccess() {
                    observer.processValue(class: String.self, response: response)
                } else {
                    if response.response?.statusCode == 409 {
                        observer.onError(SignupError.alreadyExistedNickname)
                    } else {
                        observer.processAPIError(response: response)
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    func signout() -> Observable<Void> {
        let urlString = HTTPUtils.url + "/api/v2/signout"
        let headers = HTTPUtils.defaultHeader()
        
        return self.networkManager.createDeleteObservable(urlString: urlString, headers: headers)
    }
    
    func editNickname(name: String) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            let urlString = HTTPUtils.url + "/api/v2/user/me"
            let headers = HTTPUtils.defaultHeader()
            let parameters: [String: Any] = ["name": name]
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .put,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            ).responseData { response in
                if response.isSuccess() {
                    observer.onNext(())
                    observer.onCompleted()
                } else {
                    if let editNicknameError = EditNicknameError(
                        statusCode: response.response?.statusCode
                    ) {
                        observer.onError(editNicknameError)
                    } else {
                        observer.processAPIError(response: response)
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
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
    
    func fetchUserActivity() -> Observable<User> {
        let urlString = HTTPUtils.url + "/api/v1/user/me/activity"
        let headers = HTTPUtils.defaultHeader()
        
        return self.networkManager.createGetObservable(
            class: UserWithActivityResponse.self,
            urlString: urlString,
            headers: headers
        )
        .map { User.init(response: $0) }
    }
    
    func changeMarketingConsent(marketingConsentType: MarketingConsentType) -> Observable<String> {
        let urlString = HTTPUtils.url + "/api/v1/user/me/marketing-consent"
        let header = HTTPUtils.defaultHeader()
        let parameters = ["marketingConsent": marketingConsentType.value]
        
        return self.networkManager.createPutObservable(
            class: String.self,
            urlString: urlString,
            headers: header,
            parameters: parameters
        )
    }
}
